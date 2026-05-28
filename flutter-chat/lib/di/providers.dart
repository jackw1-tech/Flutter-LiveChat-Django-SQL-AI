part of 'dependency_injector.dart';

final List<SingleChildWidget> _providers = [
  Provider<Dio>(
    create: (_) => Dio(
      BaseOptions(
        baseUrl: Apicontants.baseApiUrl, // resolved at runtime per platform
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'Content-Type': 'application/json'},
      ),
    ),
  ),
  Provider<LocalDatabase>(create: (_) => LocalDatabase.instance),
  Provider<ChatApiService>(
    create: (context) => ChatApiServiceImpl(context.read<Dio>()),
  ),
  Provider<LocalSqlService>(
    create: (context) => LocalSqlServiceImpl(context.read<LocalDatabase>()),
  ),
];
