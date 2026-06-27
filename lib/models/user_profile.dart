class UserProfile {
  const UserProfile({
    required this.uid,
    required this.nickname,
    required this.age,
    required this.interests,
    required this.visible,
    required this.premium,
  });

  final String uid;
  final String nickname;
  final int age;
  final List<String> interests;
  final bool visible;
  final bool premium;
}
