import 'package:flutter/material.dart';
import 'package:flutter_chat/di/dependency_injector.dart';
import 'package:flutter_chat/local_db/local_database.dart';
import 'package:flutter_chat/routers/app_router.dart';
import 'package:flutter_chat/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.open();
  runApp(const FlutterChatApp());
}

class FlutterChatApp extends StatelessWidget {
  const FlutterChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return DependencyInjector(
        child: MaterialApp.router(
      title: 'AI Chat',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter.config(),
    ));
  }
}
