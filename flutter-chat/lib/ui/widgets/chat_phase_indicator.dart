import 'package:flutter/material.dart';
import 'package:flutter_chat/state_management/blocs/chat_bloc/chat_bloc.dart';

class ChatPhaseIndicator extends StatelessWidget {
  final ChatStatus status;
  const ChatPhaseIndicator({super.key, required this.status});

  String? get _label {
    switch (status) {
      case ChatStatus.loadingHistory:
        return 'Loading conversation…';
      case ChatStatus.generatingQuery:
        return 'Generating SQL query…';
      case ChatStatus.executingLocalQuery:
        return 'Running query on local data…';
      case ChatStatus.waitingFinalResponse:
        return 'Composing answer…';
      case ChatStatus.idle:
      case ChatStatus.ready:
      case ChatStatus.failure:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _label;
    if (label == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
