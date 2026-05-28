import 'package:equatable/equatable.dart';

class ChatSession extends Equatable {
  final String chatId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final String? lastMessage;

  const ChatSession({
    required this.chatId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    this.lastMessage,
  });

  @override
  List<Object?> get props => [
        chatId,
        title,
        createdAt,
        updatedAt,
        messageCount,
        lastMessage,
      ];
}
