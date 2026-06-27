class HiRequest {
  const HiRequest({
    required this.requestId,
    required this.senderId,
    required this.receiverId,
    required this.status,
  });

  final String requestId;
  final String senderId;
  final String receiverId;
  final String status;
}
