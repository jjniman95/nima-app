class Pulse {
  const Pulse({
    required this.id,
    required this.nickname,
    this.bio = '',
    this.imageUrl,
    this.isVisible = true,
    this.isOnline = false,
  });

  final String id;
  final String nickname;
  final String bio;
  final String? imageUrl;
  final bool isVisible;
  final bool isOnline;

  factory Pulse.fromMap(String id, Map<String, dynamic> map) {
    return Pulse(
      id: id,
      nickname: (map['nickname'] ?? 'NIMA Pulse').toString(),
      bio: (map['bio'] ?? '').toString(),
      imageUrl: map['imageUrl']?.toString(),
      isVisible: map['visibility'] == true,
      isOnline: map['isOnline'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'nickname': nickname,
      'bio': bio,
      'imageUrl': imageUrl,
      'visibility': isVisible,
      'isOnline': isOnline,
    };
  }
}
