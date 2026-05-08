import 'package:flutter_chat/model/entities/chat_message.dart';
import 'package:flutter_chat/network/dto/chat_message_record_dto.dart';
import 'package:pine/pine.dart';
import 'package:uuid/uuid.dart';

class ChatMessageMapper extends DTOMapper<ChatMessageRecordDto, ChatMessage> {
  ChatMessageMapper({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  @override
  ChatMessage fromDTO(ChatMessageRecordDto dto) => ChatMessage(
        id: dto.id ?? _uuid.v4(),
        chatId: dto.chatId,
        role: dto.role == 'user' ? ChatRole.user : ChatRole.assistant,
        content: dto.content,
        createdAt: DateTime.tryParse(dto.createdAt ?? '') ?? DateTime.now(),
      );

  @override
  ChatMessageRecordDto toDTO(ChatMessage entity) => ChatMessageRecordDto(
        id: entity.id,
        chatId: entity.chatId,
        role: entity.role == ChatRole.user ? 'user' : 'assistant',
        content: entity.content,
        createdAt: entity.createdAt.toIso8601String(),
      );
}
