import 'package:dio/dio.dart';
import 'package:flutter_chat/network/dto/chat_dto.dart';
import 'package:flutter_chat/network/dto/chat_message_record_dto.dart';
import 'package:flutter_chat/network/service/chat_api_service.dart';

class ChatApiServiceImpl implements ChatApiService {
  ChatApiServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ChatSessionDto>> listChats() async {
    final response = await _dio.get<List<dynamic>>('/chats/');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(ChatSessionDto.fromJson)
        .toList();
  }

  @override
  Future<ChatSessionDto> createChat(ChatCreateInDto payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chats/',
      data: payload.toJson(),
    );
    return ChatSessionDto.fromJson(response.data!);
  }

  @override
  Future<List<ChatMessageRecordDto>> listMessages(String chatId) async {
    final response = await _dio.get<List<dynamic>>(
      '/chats/$chatId/messages/',
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(ChatMessageRecordDto.fromJson)
        .toList();
  }

  @override
  Future<SqlOutDto> sendMessage(MessageInDto payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/message/',
      data: payload.toJson(),
    );
    return SqlOutDto.fromJson(response.data!);
  }

  @override
  Future<FinalAnswerOutDto> processSqlResults(SqlResultsInDto payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/process_sql_results/',
      data: payload.toJson(),
    );
    return FinalAnswerOutDto.fromJson(response.data!);
  }
}
