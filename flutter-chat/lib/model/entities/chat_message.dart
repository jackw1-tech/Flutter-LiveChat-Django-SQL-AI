import 'package:equatable/equatable.dart';

/// Role of a message inside a chat conversation.
enum ChatRole { user, assistant }

/// Domain entity for a chat message — immutable, UI-friendly.
class ChatMessage extends Equatable {
  final String id;
  final String chatId;
  final ChatRole role;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  ChatMessage copyWith({
    String? id,
    String? chatId,
    ChatRole? role,
    String? content,
    DateTime? createdAt,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        role: role ?? this.role,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, chatId, role, content, createdAt];
}
