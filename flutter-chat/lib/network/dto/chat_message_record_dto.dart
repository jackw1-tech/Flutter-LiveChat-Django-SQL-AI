import 'package:pine/pine.dart';

/// Pine-compatible DTO wrapping a chat-message record (from Supabase or
/// from a local cache). Exists so [ChatMessageMapper] can extend
/// [DTOMapper], whose [Source] type parameter must extend [DTO].
class ChatMessageRecordDto extends DTO {
  final String? id;
  final String chatId;
  final String role;
  final String content;
  final String? createdAt;

  const ChatMessageRecordDto({
    required this.chatId,
    required this.role,
    required this.content,
    this.id,
    this.createdAt,
  });

  factory ChatMessageRecordDto.fromJson(Map<String, dynamic> json) =>
      ChatMessageRecordDto(
        id: json['id'] as String?,
        chatId: json['chat_id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'chat_id': chatId,
        'role': role,
        'content': content,
        if (createdAt != null) 'created_at': createdAt,
      };
}
