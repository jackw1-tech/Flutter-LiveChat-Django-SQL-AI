part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => const [];
}

class ChatStarted extends ChatEvent {
  const ChatStarted();
}

class ChatMessageSubmitted extends ChatEvent {
  final String text;
  const ChatMessageSubmitted(this.text);
  @override
  List<Object?> get props => [text];
}
