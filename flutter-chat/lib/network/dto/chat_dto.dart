/// Wire-format DTOs for the Django Ninja endpoints.
///
/// Kept dumb on purpose: serialization only. Use [ChatMessageMapper] in the
/// repository layer to translate to/from the domain entities.

class ChatCreateInDto {
  final String? title;

  const ChatCreateInDto({this.title});

  Map<String, dynamic> toJson() => {
        if (title != null && title!.trim().isNotEmpty) 'title': title,
      };
}

class ChatSessionDto {
  final String chatId;
  final String title;
  final String createdAt;
  final String updatedAt;
  final int messageCount;
  final String? lastMessage;

  const ChatSessionDto({
    required this.chatId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    this.lastMessage,
  });

  factory ChatSessionDto.fromJson(Map<String, dynamic> json) => ChatSessionDto(
        chatId: json['chat_id'] as String,
        title: json['title'] as String,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String,
        messageCount: json['message_count'] as int,
        lastMessage: json['last_message'] as String?,
      );
}

class MessageInDto {
  final String chatId;
  final String message;

  const MessageInDto({required this.chatId, required this.message});

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'message': message,
      };
}

class SqlOutDto {
  final String chatId;
  final String sql;

  const SqlOutDto({required this.chatId, required this.sql});

  factory SqlOutDto.fromJson(Map<String, dynamic> json) => SqlOutDto(
        chatId: json['chat_id'] as String,
        sql: json['sql'] as String,
      );
}

class SqlResultsInDto {
  final String chatId;
  final String userMessage;
  final String sql;
  final List<Map<String, dynamic>> rows;
  final int totalRowCount;
  final bool truncated;

  const SqlResultsInDto({
    required this.chatId,
    required this.userMessage,
    required this.sql,
    required this.rows,
    required this.totalRowCount,
    required this.truncated,
  });

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'user_message': userMessage,
        'sql': sql,
        'rows': rows,
        'total_row_count': totalRowCount,
        'truncated': truncated,
      };
}

class FinalAnswerOutDto {
  final String chatId;
  final String answer;

  const FinalAnswerOutDto({required this.chatId, required this.answer});

  factory FinalAnswerOutDto.fromJson(Map<String, dynamic> json) =>
      FinalAnswerOutDto(
        chatId: json['chat_id'] as String,
        answer: json['answer'] as String,
      );
}
