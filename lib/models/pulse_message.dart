class PulseMessage {
  const PulseMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAtLabel,
    this.seen = false,
  });

  final String id;
  final String senderId;
  final String text;
  final String sentAtLabel;
  final bool seen;

  factory PulseMessage.fromMap(String id, Map<String, dynamic> map) {
    return PulseMessage(
      id: id,
      senderId: (map['senderId'] ?? '').toString(),
      text: (map['text'] ?? '').toString(),
      sentAtLabel: (map['sentAtLabel'] ?? '').toString(),
      seen: map['seen'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAtLabel': sentAtLabel,
      'seen': seen,
    };
  }
}
