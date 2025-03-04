import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/features/chats/domain/repos/chat_repo.dart';
import 'package:socialx/features/chats/presentation/states/chat_states.dart';

class ChatCubit extends Cubit<ChatStates> {
  final ChatRepo chatRepo;

  ChatCubit({required this.chatRepo}) : super(ChatInitial());

  // Fetch Chat Messages
  Future<void> fetchChatMessages(String chatId) async {
    try {
      emit(ChatLoading());
      final messages = await chatRepo.getMessages(chatId);

      if (messages.isNotEmpty) {
        emit(ChatLoaded(messages));
      } else {
        emit(ChatEmpty());
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // Send Message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    try {
      await chatRepo.sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        text: text,
      );
      // Refresh Chat Messages after sending
      await fetchChatMessages(chatId);
    } catch (e) {
      emit(ChatError('Failed to send message')); 
    }
  }

  // Mark Messages as Read
  Future<void> markMessagesAsRead(String chatId, String messageId) async {
    try {
      await chatRepo.markMessageAsRead(chatId, messageId);
      await fetchChatMessages(chatId);
    } catch (e) {
      emit(ChatError('Failed to mark message as read'));
    }
  }
}
