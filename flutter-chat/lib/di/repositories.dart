part of 'dependency_injector.dart';

final List<RepositoryProvider> repositories = [
  RepositoryProvider<ChatRepository>(
    create: (context) => ChatRepositoryImpl(
      apiService: context.read<ChatApiService>(),
      localSqlService: context.read<LocalSqlService>(),
    ),
  ),
];
