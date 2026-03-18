import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/ai_chat_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'ai_chat_state.dart';

class AIChatBloc extends Bloc<AIChatEvent, AIChatState> {
  final AIChatRepository repository;
  final AuthRepository authRepository;

  AIChatBloc({
    required this.repository,
    required this.authRepository,
  }) : super(const AIChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ResetChatEvent>(_onResetChat);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<AIChatState> emit,
  ) async {
    final List<ChatMessage> currentMessages = List.from(state.messages);
    
    // 1. Add user message
    final userMessage = ChatMessage(
      text: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    currentMessages.add(userMessage);
    emit(AIChatLoading(currentMessages));

    try {
      // 2. Get current user ID
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(AIChatError(currentMessages, "Kamu harus login dulu ya!"));
        return;
      }

      // 3. Get AI response
      final response = await repository.getAIResponse(event.message, user.uid);
      
      // 4. Add AI message
      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      currentMessages.add(aiMessage);
      
      emit(AIChatLoaded(currentMessages));
    } catch (e) {
      emit(AIChatError(currentMessages, "Oops, terjadi kesalahan: $e"));
    }
  }

  void _onResetChat(ResetChatEvent event, Emitter<AIChatState> emit) {
    repository.resetSession();
    emit(const AIChatInitial());
  }
}
