import 'package:flutter_chat/model/entities/chat_message.dart';
import 'package:flutter_chat/network/dto/chat_dto.dart';
import 'package:flutter_chat/network/service/chat_api_service.dart';
import 'package:flutter_chat/network/service/local_sql_service.dart';
import 'package:flutter_chat/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatApiService apiService,
    required LocalSqlService localSqlService,
    Uuid? uuid,
  })  : _api = apiService,
        _local = localSqlService,
        _uuid = uuid ?? const Uuid();

  final ChatApiService _api;
  final LocalSqlService _local;
  final Uuid _uuid;

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
    final rows = await _local.runQuery(sqlOut.sql);

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
        rows: rows,
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
}
