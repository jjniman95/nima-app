enum PulseMessageType {
  text,
  aboutPulseRequest,
  aboutPulseShared,
  socialRequest,
  socialShared,
  system,
}

class PulseMessage {
  const PulseMessage({
    required this.id,
    required this.senderId,
    required this.type,
    required this.sentAtLabel,
    this.text = '',
    this.payload = const {},
    this.seen = false,
  });

  final String id;
  final String senderId;

  /// Type of message
  final PulseMessageType type;

  /// Normal text message
  final String text;

  /// Extra information for special cards
  final Map<String, dynamic> payload;

  final String sentAtLabel;
  final bool seen;

  factory PulseMessage.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final typeString = (map['type'] ?? 'text').toString();

    PulseMessageType type;

    switch (typeString) {
      case 'aboutPulseRequest':
        type = PulseMessageType.aboutPulseRequest;
        break;

      case 'aboutPulseShared':
        type = PulseMessageType.aboutPulseShared;
        break;

      case 'socialRequest':
        type = PulseMessageType.socialRequest;
        break;

      case 'socialShared':
        type = PulseMessageType.socialShared;
        break;

      case 'system':
        type = PulseMessageType.system;
        break;

      default:
        type = PulseMessageType.text;
    }

    return PulseMessage(
      id: id,
      senderId: (map['senderId'] ?? '').toString(),
      type: type,
      text: (map['text'] ?? '').toString(),
      payload: Map<String, dynamic>.from(
        map['payload'] ?? {},
      ),
      sentAtLabel: (map['sentAtLabel'] ?? '').toString(),
      seen: map['seen'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'type': type.name,
      'text': text,
      'payload': payload,
      'sentAtLabel': sentAtLabel,
      'seen': seen,
    };
  }
}
