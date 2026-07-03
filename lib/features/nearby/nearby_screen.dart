import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widgets/nima_app_bar.dart';
import '../../core/widgets/nima_avatar.dart';
import '../../core/constants/app_colors.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  int? selectedIndex;
  String? localUserId;
  String localNickname = 'NIMA User';

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
  }

  Future<void> _loadLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      localUserId = prefs.getString('localUserId');
      localNickname = prefs.getString('localNickname') ?? 'NIMA User';
    });
  }

  Color _dotColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.greenAccent;
      case 1:
        return Colors.yellowAccent;
      case 2:
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }

  String _proximityText(int index) {
    switch (index % 4) {
      case 0:
        return 'Very Close';
      case 1:
        return 'Nearby';
      case 2:
        return 'Far';
      default:
        return 'Edge of Range';
    }
  }

  Future<void> _sendHi({
    required String receiverId,
    required String receiverNickname,
  }) async {
    final senderId = localUserId;

    if (senderId == null || senderId.isEmpty) {
      _showSnack('Please create your profile first.');
      return;
    }

    if (senderId == receiverId) {
      _showSnack('This is your own profile.');
      return;
    }

    final now = Timestamp.now();
    final expiresAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(minutes: 10)),
    );

    try {
      await FirebaseFirestore.instance.collection('hi_requests').add({
        'senderId': senderId,
        'senderNickname': localNickname,
        'receiverId': receiverId,
        'receiverNickname': receiverNickname,
        'status': 'pending',
        'createdAt': now,
        'expiresAt': expiresAt,
        'lastActivityAt': now,
        'nearbyOnly': true,
        'requiresReacceptAfterMinutes': 10,
      });

      if (!mounted) return;
      Navigator.pop(context);
      _showSnack('Hi sent to $receiverNickname 👋');
    } catch (e) {
      _showSnack('Could not send Hi. Please try again.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showUserActions({
    required String userId,
    required String nickname,
    required String bio,
    required Color dotColor,
    required String proximity,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;
    final dividerColor = isDark ? Colors.white24 : Colors.black12;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: dividerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.royalPurple,
                      child: Text(
                        nickname.isNotEmpty ? nickname[0].toUpperCase() : 'N',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: sheetColor, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  nickname,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(proximity, style: TextStyle(color: mutedColor)),
                  ],
                ),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: mutedColor),
                  ),
                ],
                const SizedBox(height: 22),
                _ActionTile(
                  icon: Icons.waving_hand_rounded,
                  title: 'Say Hi',
                  subtitle: 'Send a nearby-only request',
                  color: AppColors.royalPurple,
                  onTap: () => _sendHi(receiverId: userId, receiverNickname: nickname),
                ),
                _ActionTile(
                  icon: Icons.chat_bubble_rounded,
                  title: 'Chat',
                  subtitle: 'Only after Hi is accepted',
                  color: Colors.blueGrey,
                  onTap: () {
                    Navigator.pop(context);
                    _showSnack('Chat unlocks after Hi is accepted.');
                  },
                ),
                _ActionTile(
                  icon: Icons.visibility_off_rounded,
                  title: 'Hide User',
                  subtitle: 'Hide from your radar later',
                  color: Colors.orange,
                  onTap: () => Navigator.pop(context),
                ),
                _ActionTile(
                  icon: Icons.block_rounded,
                  title: 'Block User',
                  subtitle: 'Block future interaction later',
                  color: Colors.red,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: NimaAppBar(
  title: "Nearby",
  actions: [
    IconButton(
      onPressed: () {},
      icon: const Icon(Icons.tune_rounded),
    ),
  ],
),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _usersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong loading nearby users.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.where((doc) => doc.id != localUserId).toList();

          if (users.isEmpty) {
            return const Center(child: Text('No nearby Pulses yet.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final radarSize = math.min(constraints.maxWidth - 32, 430.0);
              final visibleCount = math.min(users.length, 10);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: radarSize,
                      height: radarSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _RadarBackground(size: radarSize),
                          const _CenterMarker(),
                          ...List.generate(visibleCount, (index) {
                            final doc = users[index];
                            final data = doc.data();
                            final nickname = (data['nickname'] ?? 'NIMA User').toString();
                            final bio = (data['bio'] ?? '').toString();
                            final angle = (2 * math.pi / visibleCount) * index - math.pi / 2;
                            final radius = radarSize * (0.28 + (index % 3) * 0.12);
                            final x = math.cos(angle) * radius;
                            final y = math.sin(angle) * radius;
                            final active = selectedIndex == index;
                            final dotColor = _dotColor(index);
                            final proximity = _proximityText(index);

                            return Transform.translate(
                              offset: Offset(x, y),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => selectedIndex = index);
                                  _showUserActions(
                                    userId: doc.id,
                                    nickname: nickname,
                                    bio: bio,
                                    dotColor: dotColor,
                                    proximity: proximity,
                                  );
                                },
                                child: _RadarUserBubble(
                                  nickname: nickname,
                                  dotColor: dotColor,
                                  active: active,
                                  isDark: isDark,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _StatusCard(userCount: users.length),
                    const SizedBox(height: 14),
                    const _LegendCard(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RadarBackground extends StatelessWidget {
  const _RadarBackground({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isDark
              ? const [Color(0xFF24124A), Color(0xFF111A2D)]
              : const [Color(0xFFF7F2FF), Color(0xFFEFF6FF)],
        ),
        border: Border.all(
          color: isDark
              ? AppColors.royalPurple.withOpacity(0.45)
              : AppColors.royalPurple.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.royalPurple.withOpacity(0.16)
                : Colors.black.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(painter: _RadarPainter(isDark: isDark)),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = isDark
          ? AppColors.royalPurple.withOpacity(0.45)
          : AppColors.royalPurple.withOpacity(0.22);

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, size.width * i / 9, ringPaint);
    }

    final linePaint = Paint()
      ..strokeWidth = 1
      ..color = isDark
          ? Colors.white.withOpacity(0.05)
          : AppColors.royalPurple.withOpacity(0.08);

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _CenterMarker extends StatelessWidget {
  const _CenterMarker();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white : AppColors.textDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.royalPurple.withOpacity(0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.royalPurple.withOpacity(0.38),
                blurRadius: 22,
              ),
            ],
          ),
          child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 6),
        Text('You', style: TextStyle(fontWeight: FontWeight.w800, color: labelColor)),
      ],
    );
  }
}

class _RadarUserBubble extends StatelessWidget {
  const _RadarUserBubble({
    required this.nickname,
    required this.dotColor,
    required this.active,
    required this.isDark,
  });

  final String nickname;
  final Color dotColor;
  final bool active;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? Colors.white : AppColors.textDark;

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: active ? 1.16 : 1.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NimaAvatar(
            nickname: nickname,
            statusColor: dotColor,
            size: 50,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 70,
            child: Text(
              nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.userCount});

  final int userCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: AppColors.royalPurple, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby Pulses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$userCount Pulses nearby',
                  style: TextStyle(color: mutedColor),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: const Wrap(
        spacing: 14,
        runSpacing: 12,
        children: [
          _LegendItem(color: Colors.greenAccent, text: 'Very Close'),
          _LegendItem(color: Colors.yellowAccent, text: 'Nearby'),
          _LegendItem(color: Colors.orangeAccent, text: 'Far'),
          _LegendItem(color: Colors.redAccent, text: 'Edge'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
          ),
        ),
        const SizedBox(width: 7),
        Text(text, style: TextStyle(color: textColor)),
      ],
    );
  }
}
}
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        tileColor: color.withOpacity(isDark ? 0.18 : 0.10),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: mutedColor),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: mutedColor,
        ),
      ),
    );
  }
}
