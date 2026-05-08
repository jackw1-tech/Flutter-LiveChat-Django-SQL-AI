part of 'dependency_injector.dart';

final List<SingleChildWidget> _mappers = [
  Provider<ChatMessageMapper>(create: (_) => ChatMessageMapper()),
];
