part of 'dependency_injector.dart';

final List<BlocProvider> blocs = [
  BlocProvider<ChatBloc>(
    create: (context) =>
        ChatBloc(repository: context.read<ChatRepository>())..add(const ChatStarted()),
  ),
];
