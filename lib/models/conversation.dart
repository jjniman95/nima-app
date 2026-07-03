class PulseConversation {
  const PulseConversation({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.status,
    required this.mergeState,
    this.lastMessage = '',
  });

  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String status;
  final String mergeState;
  final String lastMessage;

  bool get isMerged => mergeState == 'merged';
  bool get isExpired => mergeState == 'expired';

  factory PulseConversation.fromMap(String id, Map<String, dynamic> map) {
    final rawParticipants = map['participants'];
    final rawNames = map['participantNames'];

    return PulseConversation(
      id: id,
      participants: rawParticipants is List
          ? rawParticipants.map((e) => e.toString()).toList()
          : const [],
      participantNames: rawNames is Map
          ? rawNames.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : const {},
      status: (map['status'] ?? 'active').toString(),
      mergeState: (map['mergeState'] ?? 'merged').toString(),
      lastMessage: (map['lastMessage'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'status': status,
      'mergeState': mergeState,
      'lastMessage': lastMessage,
    };
  }
}
