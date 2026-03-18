import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp];
}

abstract class AIChatEvent extends Equatable {
  const AIChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends AIChatEvent {
  final String message;
  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetChatEvent extends AIChatEvent {}

abstract class AIChatState extends Equatable {
  final List<ChatMessage> messages;
  const AIChatState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class AIChatInitial extends AIChatState {
  const AIChatInitial() : super(const []);
}

class AIChatLoading extends AIChatState {
  const AIChatLoading(super.messages);
}

class AIChatLoaded extends AIChatState {
  const AIChatLoaded(super.messages);
}

class AIChatError extends AIChatState {
  final String error;
  const AIChatError(super.messages, this.error);

  @override
  List<Object?> get props => [messages, error];
}
