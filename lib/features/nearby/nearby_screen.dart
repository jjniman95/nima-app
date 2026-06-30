import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  int? selectedIndex;

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

  void _showUserActions({
    required String nickname,
    required String bio,
    required Color dotColor,
    required String proximity,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
  child: SingleChildScrollView(
    child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
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
                          border: Border.all(color: AppColors.darkSurface, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  nickname,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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
                    Text(
                      proximity,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
                const SizedBox(height: 22),
                _ActionTile(
                  icon: Icons.waving_hand_rounded,
                  title: 'Say Hi',
                  subtitle: 'Send a hi request',
                  color: AppColors.royalPurple,
                  onTap: () => Navigator.pop(context),
                ),
                _ActionTile(
                  icon: Icons.chat_bubble_rounded,
                  title: 'Chat',
                  subtitle: 'Available after Hi is accepted',
                  color: Colors.blueGrey,
                  onTap: () => Navigator.pop(context),
                ),
                _ActionTile(
                  icon: Icons.visibility_off_rounded,
                  title: 'Hide User',
                  subtitle: 'Hide from your radar',
                  color: Colors.orange,
                  onTap: () => Navigator.pop(context),
                ),
                _ActionTile(
                  icon: Icons.block_rounded,
                  title: 'Block User',
                  subtitle: 'Block future interaction',
                  color: Colors.red,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
         ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No users yet.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final radarSize = math.min(width - 32, 430.0);

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
                          _CenterMarker(),
                          ...List.generate(users.length.clamp(0, 10), (index) {
                            final data = users[index].data();
                            final nickname = (data['nickname'] ?? 'NIMA User').toString();
                            final bio = (data['bio'] ?? '').toString();

                            final angle = (2 * math.pi / users.length) * index - math.pi / 2;
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
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFF24124A),
            Color(0xFF111A2D),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _RadarPainter(),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.royalPurple.withOpacity(0.45);

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, size.width * i / 9, paint);
    }

    final linePaint = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.05);

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CenterMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.royalPurple.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.royalPurple.withOpacity(0.45),
                blurRadius: 22,
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'You',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _RadarUserBubble extends StatelessWidget {
  const _RadarUserBubble({
    required this.nickname,
    required this.dotColor,
    required this.active,
  });

  final String nickname;
  final Color dotColor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final initial = nickname.isNotEmpty ? nickname[0].toUpperCase() : 'N';

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: active ? 1.16 : 1.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.royalPurple : Colors.white24,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.royalPurple.withOpacity(active ? 0.65 : 0.25),
                      blurRadius: active ? 20 : 10,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.accentPurple,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 2,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF111A2D),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 70,
            child: Text(
              nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.userCount});

  final int userCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: AppColors.royalPurple, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nearby Users',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '$userCount people nearby',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
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
  const _LegendItem({
    required this.color,
    required this.text,
  });

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(text),
      ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: color.withOpacity(0.18),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
