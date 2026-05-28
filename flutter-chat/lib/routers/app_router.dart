import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/ui/pages/chat_list_page.dart';
import 'package:flutter_chat/ui/pages/chat_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/', page: ChatListRoute.page, initial: true),
        AutoRoute(path: '/chat/:chatId', page: ChatRoute.page),
      ];
}
