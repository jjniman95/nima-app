import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../conversation/conversation_screen.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class MergingPulsesScreen extends StatefulWidget {
  const MergingPulsesScreen({
    super.key,
    required this.conversationId,
    required this.otherPulseName,
  });

  final String conversationId;
  final String otherPulseName;

  @override
  State<MergingPulsesScreen> createState() => _MergingPulsesScreenState();
}

class _MergingPulsesScreenState extends State<MergingPulsesScreen> {
  bool merged = false;

  @override
  void initState() {
    super.initState();
    _startMerge();
  }

  Future<void> _startMerge() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => merged = true);

    final expiresAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(minutes: 10)),
    );

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .update({
      'mergeState': 'merged',
      'status': 'active',
      'mergedAt': FieldValue.serverTimestamp(),
      'lastActivityAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (_) => ConversationScreen(
      pulseName: widget.otherPulseName,
    ),
  ),
);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PulseMergeAnimation(merged: merged),
                const SizedBox(height: 34),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    merged ? 'Pulses Merged' : 'Merging Pulses...',
                    key: ValueKey(merged),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  merged
                      ? 'Conversation with ${widget.otherPulseName} is active.'
                      : 'Creating a nearby-only temporary merge.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Merge expires after 10 minutes of inactivity.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseMergeAnimation extends StatefulWidget {
  const _PulseMergeAnimation({required this.merged});

  final bool merged;

  @override
  State<_PulseMergeAnimation> createState() => _PulseMergeAnimationState();
}

class _PulseMergeAnimationState extends State<_PulseMergeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> pulseScale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    pulseScale = Tween<double>(begin: 0.92, end: 1.16).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: pulseScale,
            child: Container(
              width: widget.merged ? 130 : 180,
              height: widget.merged ? 130 : 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.royalPurple.withOpacity(0.35),
                  width: 2,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            left: widget.merged ? 88 : 34,
            child: _PulseDot(
              icon: Icons.person_rounded,
              glow: !widget.merged,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            right: widget.merged ? 88 : 34,
            child: _PulseDot(
              icon: Icons.person_rounded,
              glow: !widget.merged,
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: widget.merged ? 1 : 0,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.royalPurple,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.royalPurple.withOpacity(0.65),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({
    required this.icon,
    required this.glow,
  });

  final IconData icon;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentPurple,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(glow ? 0.55 : 0.2),
            blurRadius: glow ? 26 : 12,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
