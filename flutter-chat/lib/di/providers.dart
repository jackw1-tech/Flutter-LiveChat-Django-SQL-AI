part of 'dependency_injector.dart';

final List<SingleChildWidget> _providers = [
  Provider<Dio>(
    create: (_) => Dio(
      BaseOptions(
        baseUrl: Apicontants.baseApiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 60),
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
