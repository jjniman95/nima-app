class HiRequest {
  const HiRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderNickname,
    required this.receiverNickname,
    required this.status,
    this.conversationId,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String senderNickname;
  final String receiverNickname;
  final String status;
  final String? conversationId;

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isExpired => status == 'expired';

  factory HiRequest.fromMap(String id, Map<String, dynamic> map) {
    return HiRequest(
      id: id,
      senderId: (map['senderId'] ?? '').toString(),
      receiverId: (map['receiverId'] ?? '').toString(),
      senderNickname: (map['senderNickname'] ?? 'Pulse').toString(),
      receiverNickname: (map['receiverNickname'] ?? 'Pulse').toString(),
      status: (map['status'] ?? 'pending').toString(),
      conversationId: map['conversationId']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderNickname': senderNickname,
      'receiverNickname': receiverNickname,
      'status': status,
      'conversationId': conversationId,
    };
  }
}
