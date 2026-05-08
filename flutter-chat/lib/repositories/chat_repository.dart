import 'package:flutter_chat/model/entities/chat_message.dart';

/// Domain-facing contract used by the BLoC. The implementation hides the
/// SQL-then-answer dance behind a single stream so the presentation layer
/// just renders phase updates.
abstract class ChatRepository {
  /// Drive the full pipeline:
  ///   1) POST message -> SQL
  ///   2) execute SQL on local sqflite
  ///   3) POST rows -> final natural-language answer
  ///
  /// Yields [ChatPipelineUpdate]s so the BLoC can switch into intermediate
  /// loading states (generating query, running locally, awaiting answer).
  Stream<ChatPipelineUpdate> ask({
    required String chatId,
    required String userMessage,
  });
}

/// Discrete steps of the multi-phase pipeline, surfaced to the BLoC.
enum ChatPipelinePhase {
  generatingQuery,
  executingLocalQuery,
  waitingFinalResponse,
  completed,
}

class ChatPipelineUpdate {
  final ChatPipelinePhase phase;

  /// Populated only on [ChatPipelinePhase.completed].
  final ChatMessage? assistantMessage;

  /// Populated as soon as the SQL is generated, useful for debugging UIs.
  final String? sql;

  const ChatPipelineUpdate({
    required this.phase,
    this.assistantMessage,
    this.sql,
  });
}
