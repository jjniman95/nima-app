import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/nima_app_bar.dart';
import '../conversation/conversation_screen.dart';

class MergesScreen extends StatefulWidget {
  const MergesScreen({super.key});

  @override
  State<MergesScreen> createState() => _MergesScreenState();
}

class _MergesScreenState extends State<MergesScreen> {
  String? localUserId;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadLocalUser();

    refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalUser() async {
    final prefs = await SharedPreferences.getInstance();

    var id = prefs.getString('localUserId');

    if (id == null || id.isEmpty) {
      id = 'local_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('localUserId', id);
    }

    if (!mounted) return;

    setState(() {
      localUserId = id;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _mergesStream(String userId) {
    return FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots();
  }

  String _otherPulseName(Map<String, dynamic> data, String userId) {
    final names = data['participantNames'];

    if (names is Map) {
      for (final entry in names.entries) {
        if (entry.key.toString() != userId) {
          return entry.value.toString();
        }
      }
    }

    return 'Pulse';
  }

  Duration _remaining(Map<String, dynamic> data) {
    final expiresAt = data['expiresAt'];

    if (expiresAt is! Timestamp) {
      return const Duration(minutes: 10);
    }

    final diff = expiresAt.toDate().difference(DateTime.now());

    if (diff.isNegative) {
      return Duration.zero;
    }

    return diff;
  }

  String _timerText(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool _isActiveMerge(Map<String, dynamic> data) {
    final status = (data['status'] ?? '').toString();
    final mergeState = (data['mergeState'] ?? '').toString();

    if (status != 'active') return false;
    if (mergeState != 'merged') return false;
    if (_remaining(data).inSeconds <= 0) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final userId = localUserId;

    return Scaffold(
      appBar: const NimaAppBar(
        title: 'Merges',
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _mergesStream(userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load active merges.'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final merges = snapshot.data!.docs.where((doc) {
                  return _isActiveMerge(doc.data());
                }).toList();

                merges.sort((a, b) {
                  final aTime = a.data()['lastMessageAt'];
                  final bTime = b.data()['lastMessageAt'];

                  if (aTime is Timestamp && bTime is Timestamp) {
                    return bTime.compareTo(aTime);
                  }

                  return 0;
                });

                if (merges.isEmpty) {
                  return const _EmptyMergesView();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: merges.length,
                  itemBuilder: (context, index) {
                    final doc = merges[index];
                    final data = doc.data();

                    final otherName = _otherPulseName(data, userId);
                    final lastMessage =
                        (data['lastMessage'] ?? 'Merge is active.').toString();
                    final remaining = _remaining(data);

                    return _MergeCard(
                      pulseName: otherName,
                      lastMessage: lastMessage.isEmpty
                          ? 'Merge is active.'
                          : lastMessage,
                      timerText: _timerText(remaining),
                      warning: remaining.inSeconds <= 120,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ConversationScreen(
                              conversationId: doc.id,
                              pulseName: otherName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class _EmptyMergesView extends StatelessWidget {
  const _EmptyMergesView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.royalPurple.withOpacity(0.14),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.royalPurple,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No active merges',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Accepted Hi requests will appear here until the merge expires.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MergeCard extends StatelessWidget {
  const _MergeCard({
    required this.pulseName,
    required this.lastMessage,
    required this.timerText,
    required this.warning,
    required this.onTap,
  });

  final String pulseName;
  final String lastMessage;
  final String timerText;
  final bool warning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;
    final timerColor = warning ? Colors.orange : AppColors.royalPurple;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black12,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.royalPurple,
                child: Text(
                  pulseName.isNotEmpty ? pulseName[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pulseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: mutedColor),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: timerColor,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$timerText remaining',
                          style: TextStyle(
                            color: timerColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: mutedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
