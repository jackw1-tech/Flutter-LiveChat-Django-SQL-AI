import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/routers/auth_guard.dart';
import 'package:flutter_chat/ui/pages/chat_page.dart';
import 'package:flutter_chat/ui/pages/detail_page.dart';
import 'package:flutter_chat/ui/pages/home_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/', page: ChatRoute.page, initial: true),
    AutoRoute(path: '/legacy', page: HomeRoute.page),
    AutoRoute(
      path: '/detail/:id',
      page: ExampleDetailRoute.page,
      guards: [AuthGuard()],
    ),
  ];
}
