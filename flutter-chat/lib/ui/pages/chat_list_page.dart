import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/model/entities/chat_session.dart';
import 'package:flutter_chat/repositories/chat_repository.dart';
import 'package:flutter_chat/routers/app_router.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late Future<List<ChatSession>> _chatsFuture;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _chatsFuture = context.read<ChatRepository>().listChats();
  }

  Future<void> _openChat(ChatSession chat) async {
    await context.router.push(ChatRoute(chatId: chat.chatId));
    if (!mounted) return;
    setState(_refresh);
  }

  Future<void> _createChat() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final chat = await context.read<ChatRepository>().createChat();
      if (!mounted) return;
      await _openChat(chat);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  String _subtitle(ChatSession chat) {
    final last = chat.lastMessage;
    if (last == null || last.trim().isEmpty) {
      return 'Nessun messaggio';
    }
    return last;
  }

  String _dateLabel(BuildContext context, DateTime date) {
    final local = date.toLocal();
    final time = TimeOfDay.fromDateTime(local).format(context);
    final day = MaterialLocalizations.of(context).formatShortDate(local);
    return '$day $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: FutureBuilder<List<ChatSession>>(
        future: _chatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => setState(_refresh),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            );
          }

          final chats = snapshot.data ?? const <ChatSession>[];
          if (chats.isEmpty) {
            return Center(
              child: FilledButton.icon(
                onPressed: _creating ? null : _createChat,
                icon: const Icon(Icons.add_comment_outlined),
                label: const Text('Nuova chat'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(_refresh);
              await _chatsFuture;
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
                  title: Text(
                    chat.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _subtitle(chat),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _dateLabel(context, chat.updatedAt),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () => _openChat(chat),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _creating ? null : _createChat,
        child: _creating
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
    );
  }
}
