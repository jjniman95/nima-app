class ChatMessage {
  const ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.message,
    required this.sentAt,
    this.read = false,
  });

  final String messageId;
  final String senderId;
  final String message;
  final DateTime sentAt;
  final bool read;
}
