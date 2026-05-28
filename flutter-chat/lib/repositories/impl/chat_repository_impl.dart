import 'package:flutter_chat/model/entities/chat_message.dart';
import 'package:flutter_chat/model/entities/chat_session.dart';
import 'package:flutter_chat/mappers/chat_message_mapper.dart';
import 'package:flutter_chat/network/dto/chat_dto.dart';
import 'package:flutter_chat/network/service/chat_api_service.dart';
import 'package:flutter_chat/network/service/local_sql_service.dart';
import 'package:flutter_chat/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatApiService apiService,
    required LocalSqlService localSqlService,
    required ChatMessageMapper chatMessageMapper,
    Uuid? uuid,
  })  : _api = apiService,
        _local = localSqlService,
        _chatMessageMapper = chatMessageMapper,
        _uuid = uuid ?? const Uuid();

  final ChatApiService _api;
  final LocalSqlService _local;
  final ChatMessageMapper _chatMessageMapper;
  final Uuid _uuid;

  @override
  Future<List<ChatSession>> listChats() async {
    final chats = await _api.listChats();
    return chats.map(_mapSession).toList();
  }

  @override
  Future<ChatSession> createChat() async {
    final chat = await _api.createChat(const ChatCreateInDto());
    return _mapSession(chat);
  }

  @override
  Future<List<ChatMessage>> listMessages(String chatId) async {
    final messages = await _api.listMessages(chatId);
    return messages.map(_chatMessageMapper.fromDTO).toList();
  }

  @override
  Stream<ChatPipelineUpdate> ask({
    required String chatId,
    required String userMessage,
  }) async* {
    // Phase A — Flutter -> Django -> OpenAI -> SQL.
    yield const ChatPipelineUpdate(phase: ChatPipelinePhase.generatingQuery);
    final sqlOut = await _api.sendMessage(
      MessageInDto(chatId: chatId, message: userMessage),
    );

    // Phase B — Flutter executes the SQL on the on-device sqflite database.
    yield ChatPipelineUpdate(
      phase: ChatPipelinePhase.executingLocalQuery,
      sql: sqlOut.sql,
    );
    // ignore: avoid_print
    print('[SQL generated] ${sqlOut.sql}');
    final result = await _local.runQuery(sqlOut.sql);
    // ignore: avoid_print
    print('[SQL executed]  ${result.executedSql}');
    // ignore: avoid_print
    print('[SQL result]    rows=${result.rows.length}  total=${result.totalRowCount}  truncated=${result.truncated}');

    // Phase C — Flutter -> Django -> OpenAI -> final natural-language reply.
    yield ChatPipelineUpdate(
      phase: ChatPipelinePhase.waitingFinalResponse,
      sql: sqlOut.sql,
    );
    final answer = await _api.processSqlResults(
      SqlResultsInDto(
        chatId: chatId,
        userMessage: userMessage,
        sql: sqlOut.sql,
        rows: result.rows,
        totalRowCount: result.totalRowCount,
        truncated: result.truncated,
      ),
    );

    yield ChatPipelineUpdate(
      phase: ChatPipelinePhase.completed,
      sql: sqlOut.sql,
      assistantMessage: ChatMessage(
        id: _uuid.v4(),
        chatId: chatId,
        role: ChatRole.assistant,
        content: answer.answer,
        createdAt: DateTime.now(),
      ),
    );
  }

  ChatSession _mapSession(ChatSessionDto dto) => ChatSession(
        chatId: dto.chatId,
        title: dto.title,
        createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(dto.updatedAt) ?? DateTime.now(),
        messageCount: dto.messageCount,
        lastMessage: dto.lastMessage,
      );
}
