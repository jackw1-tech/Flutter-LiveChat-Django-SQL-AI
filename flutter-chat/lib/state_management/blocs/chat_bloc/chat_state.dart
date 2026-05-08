part of 'chat_bloc.dart';

/// Coarse pipeline status surfaced to the UI.
enum ChatStatus {
  idle,
  generatingQuery,
  executingLocalQuery,
  waitingFinalResponse,
  ready,
  failure,
}

class ChatState extends Equatable {
  final String chatId;
  final List<ChatMessage> messages;
  final ChatStatus status;
  final String? lastSql;
  final String? errorMessage;

  const ChatState({
    required this.chatId,
    this.messages = const [],
    this.status = ChatStatus.idle,
    this.lastSql,
    this.errorMessage,
  });

  bool get isBusy =>
      status == ChatStatus.generatingQuery ||
      status == ChatStatus.executingLocalQuery ||
      status == ChatStatus.waitingFinalResponse;

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
    String? lastSql,
    String? errorMessage,
    bool clearError = false,
  }) =>
      ChatState(
        chatId: chatId,
        messages: messages ?? this.messages,
        status: status ?? this.status,
        lastSql: lastSql ?? this.lastSql,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [chatId, messages, status, lastSql, errorMessage];
}
