/// Wire-format DTOs for the Django Ninja endpoints.
///
/// Kept dumb on purpose: serialization only. Use [ChatMessageMapper] in the
/// repository layer to translate to/from the domain entities.

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

  const SqlResultsInDto({
    required this.chatId,
    required this.userMessage,
    required this.sql,
    required this.rows,
  });

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'user_message': userMessage,
        'sql': sql,
        'rows': rows,
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
