import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/nima_avatar.dart';

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

  void _openProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    NimaAvatar(
                      nickname: localNickname,
                      statusColor: Colors.greenAccent,
                      size: 56,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        localNickname,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _MenuTile(
                  icon: Icons.person_rounded,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    _showSnack('Profile will open here.');
                  },
                ),
                _MenuTile(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    _showSnack('Settings will open here.');
                  },
                ),
                _MenuTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Contact Us',
                  onTap: () {
                    Navigator.pop(context);
                    _showSnack('Contact Us will open here.');
                  },
                ),
                _MenuTile(
                  icon: Icons.info_rounded,
                  title: 'About NIMA',
                  onTap: () {
                    Navigator.pop(context);
                    _showSnack('About NIMA will open here.');
                  },
                ),
              ],
            ),
          ),
        );
      },
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
                NimaAvatar(
                  nickname: nickname,
                  statusColor: dotColor,
                  size: 88,
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
                  onTap: () => _sendHi(
                    receiverId: userId,
                    receiverNickname: nickname,
                  ),
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
    final background =
        isDark ? AppColors.darkBackground : const Color(0xFFF7F5FF);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _NearbyHeader(
              nickname: localNickname,
              onAvatarTap: _openProfileMenu,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _usersStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong loading nearby users.'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs
                      .where((doc) => doc.id != localUserId)
                      .toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final radarSize =
                          math.min(constraints.maxWidth - 32, 430.0);
                      final visibleCount = math.min(users.length, 10);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              'Nearby Pulses',
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.textDark,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'People around you',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : AppColors.textMuted,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: radarSize,
                              height: radarSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedRadarBackground(size: radarSize),
                                  ...List.generate(visibleCount, (index) {
                                    final doc = users[index];
                                    final data = doc.data();

                                    final nickname =
                                        (data['nickname'] ?? 'NIMA User')
                                            .toString();
                                    final bio = (data['bio'] ?? '').toString();

                                    final angle =
                                        (2 * math.pi / math.max(visibleCount, 1)) *
                                                index -
                                            math.pi / 2;
                                    final radius = radarSize *
                                        (0.24 + (index % 4) * 0.105);
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
                                  if (users.isEmpty)
                                    _EmptyRadarHint(isDark: isDark),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            _StatusCard(userCount: users.length),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyHeader extends StatelessWidget {
  const _NearbyHeader({
    required this.nickname,
    required this.onAvatarTap,
  });

  final String nickname;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 20, 6),
      child: Row(
        children: [
          Text(
            'NIMA',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textDark,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.royalPurple.withOpacity(0.65),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.royalPurple.withOpacity(0.28),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: NimaAvatar(
                nickname: nickname,
                statusColor: AppColors.royalPurple,
                size: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedRadarBackground extends StatefulWidget {
  const AnimatedRadarBackground({
    super.key,
    required this.size,
  });

  final double size;

  @override
  State<AnimatedRadarBackground> createState() =>
      _AnimatedRadarBackgroundState();
}

class _AnimatedRadarBackgroundState extends State<AnimatedRadarBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _AnimatedRadarPainter(
            progress: controller.value,
            isDark: isDark,
          ),
        );
      },
    );
  }
}

class _AnimatedRadarPainter extends CustomPainter {
  _AnimatedRadarPainter({
    required this.progress,
    required this.isDark,
  });

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? const [
                Color(0xFF36106E),
                Color(0xFF120B25),
                Color(0xFF0E1629),
              ]
            : const [
                Color(0xFFF3E9FF),
                Color(0xFFEFF3FF),
                Colors.white,
              ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawCircle(center, radius, bgPaint);

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.royalPurple.withOpacity(isDark ? 0.62 : 0.28);

    canvas.drawCircle(center, radius - 2, outerPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..color = AppColors.royalPurple.withOpacity(isDark ? 0.34 : 0.20);

    for (int i = 1; i <= 7; i++) {
      canvas.drawCircle(center, radius * i / 8, ringPaint);
    }

    final linePaint = Paint()
      ..strokeWidth = 1
      ..color = AppColors.royalPurple.withOpacity(isDark ? 0.24 : 0.13);

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);

    final angle = progress * 2 * math.pi - math.pi / 2;

    final beamPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius - 4),
        angle,
        math.pi / 4,
        false,
      )
      ..close();

    final beamPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.royalPurple.withOpacity(0.0),
          AppColors.royalPurple.withOpacity(isDark ? 0.28 : 0.18),
          AppColors.royalPurple.withOpacity(isDark ? 0.48 : 0.28),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(beamPath, beamPaint);

    final beamLinePaint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(isDark ? 0.85 : 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawLine(
      center,
      Offset(
        center.dx + math.cos(angle + math.pi / 4) * (radius - 8),
        center.dy + math.sin(angle + math.pi / 4) * (radius - 8),
      ),
      beamLinePaint,
    );

    final centerGlow = Paint()
      ..color = AppColors.royalPurple.withOpacity(0.72)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawCircle(center, 20, centerGlow);

    final centerDot = Paint()..color = Colors.white;
    canvas.drawCircle(center, 5, centerDot);

    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(isDark ? 0.85 : 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final particleAngles = [
      math.pi * 0.15,
      math.pi * 0.72,
      math.pi * 1.25,
      math.pi * 1.68,
      math.pi * 1.92,
    ];

    for (int i = 0; i < particleAngles.length; i++) {
      final pr = radius * (0.35 + (i % 3) * 0.18);
      final a = particleAngles[i];
      canvas.drawCircle(
        Offset(center.dx + math.cos(a) * pr, center.dy + math.sin(a) * pr),
        2.2,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedRadarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
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
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.royalPurple.withOpacity(0.55),
                  blurRadius: 18,
                ),
              ],
            ),
            child: NimaAvatar(
              nickname: nickname,
              statusColor: dotColor,
              size: 52,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 78,
            child: Text(
              nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: labelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRadarHint extends StatelessWidget {
  const _EmptyRadarHint({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Scanning...',
      style: TextStyle(
        color: isDark ? Colors.white60 : AppColors.textMuted,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.royalPurple.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: AppColors.royalPurple,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userCount == 0
                      ? 'Scanning for nearby Pulses...'
                      : '$userCount Pulses nearby',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Make sure NIMA is open on nearby devices.',
                  style: TextStyle(color: mutedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.royalPurple),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
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
