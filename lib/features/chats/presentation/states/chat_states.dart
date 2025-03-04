abstract class ChatStates {}

class ChatInitial extends ChatStates {}

class ChatLoading extends ChatStates {}

class ChatLoaded extends ChatStates {
  final List<Map<String, dynamic>> messages;

  ChatLoaded(this.messages);
}

class ChatEmpty extends ChatStates {}

class ChatError extends ChatStates {
  final String error;

  ChatError(this.error);
}
