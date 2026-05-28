// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ChatListPage]
class ChatListRoute extends PageRouteInfo<void> {
  const ChatListRoute({List<PageRouteInfo>? children})
      : super(ChatListRoute.name, initialChildren: children);

  static const String name = 'ChatListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatListPage();
    },
  );
}

/// generated route for
/// [ChatPage]
class ChatRoute extends PageRouteInfo<ChatRouteArgs> {
  ChatRoute({
    required String chatId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ChatRoute.name,
          args: ChatRouteArgs(chatId: chatId, key: key),
          rawPathParams: {'chatId': chatId},
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatRouteArgs>(
        orElse: () => ChatRouteArgs(chatId: pathParams.getString('chatId')),
      );
      return ChatPage(chatId: args.chatId, key: args.key);
    },
  );
}

class ChatRouteArgs {
  const ChatRouteArgs({required this.chatId, this.key});

  final String chatId;

  final Key? key;

  @override
  String toString() {
    return 'ChatRouteArgs{chatId: $chatId, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRouteArgs) return false;
    return chatId == other.chatId && key == other.key;
  }

  @override
  int get hashCode => chatId.hashCode ^ key.hashCode;
}
