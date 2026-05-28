import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/model/entities/chat_message.dart';
import 'package:flutter_chat/network/service/local_sql_service.dart';
import 'package:flutter_chat/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required ChatRepository repository,
    String? chatId,
    Uuid? uuid,
  })  : _repository = repository,
        _uuid = uuid ?? const Uuid(),
        super(ChatState(chatId: chatId ?? (uuid ?? const Uuid()).v4())) {
    on<ChatStarted>(_onStarted);
    on<ChatMessageSubmitted>(_onSubmitted);
  }

  final ChatRepository _repository;
  final Uuid _uuid;

  Future<void> _onStarted(
    ChatStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loadingHistory, clearError: true));
    try {
      final messages = await _repository.listMessages(state.chatId);
      emit(state.copyWith(messages: messages, status: ChatStatus.ready));
    } catch (error) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onSubmitted(
    ChatMessageSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    if (state.isBusy || event.text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      chatId: state.chatId,
      role: ChatRole.user,
      content: event.text.trim(),
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      status: ChatStatus.generatingQuery,
      clearError: true,
    ));

    try {
      await emit.forEach<ChatPipelineUpdate>(
        _repository.ask(
          chatId: state.chatId,
          userMessage: userMessage.content,
        ),
        onData: (update) {
          switch (update.phase) {
            case ChatPipelinePhase.generatingQuery:
              return state.copyWith(status: ChatStatus.generatingQuery);
            case ChatPipelinePhase.executingLocalQuery:
              return state.copyWith(
                status: ChatStatus.executingLocalQuery,
                lastSql: update.sql,
              );
            case ChatPipelinePhase.waitingFinalResponse:
              return state.copyWith(
                status: ChatStatus.waitingFinalResponse,
                lastSql: update.sql,
              );
            case ChatPipelinePhase.completed:
              final assistant = update.assistantMessage!;
              return state.copyWith(
                messages: [...state.messages, assistant],
                status: ChatStatus.ready,
                lastSql: update.sql,
              );
          }
        },
      );
    } on UnsafeSqlException {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: 'Non sono riuscito a elaborare la domanda. Prova a riformularla.',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }
}
