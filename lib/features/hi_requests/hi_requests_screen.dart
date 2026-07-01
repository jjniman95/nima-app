import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';

class HiRequestsScreen extends StatefulWidget {
  const HiRequestsScreen({super.key});

  @override
  State<HiRequestsScreen> createState() => _HiRequestsScreenState();
}

class _HiRequestsScreenState extends State<HiRequestsScreen> {
  String? localUserId;

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
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

  Stream<QuerySnapshot<Map<String, dynamic>>> _requestsStream() {
    return FirebaseFirestore.instance
        .collection('hi_requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  bool _isExpired(Map<String, dynamic> data) {
    final expiresAt = data['expiresAt'];
    if (expiresAt is! Timestamp) return false;
    return DateTime.now().isAfter(expiresAt.toDate());
  }

  String _statusText(Map<String, dynamic> data) {
    if (_isExpired(data)) return 'Merge Expired';

    final status = (data['status'] ?? 'pending').toString();

    switch (status) {
      case 'accepted':
        return 'Pulses Merged';
      case 'declined':
        return 'Hi Declined';
      default:
        return 'Incoming Hi';
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    final now = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection('hi_requests')
        .doc(requestId)
        .update({
      'status': 'accepted',
      'acceptedAt': now,
      'lastActivityAt': now,
      'mergeExpiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 10)),
      ),
      'updatedAt': now,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pulses Merged ✨')),
    );
  }

  Future<void> _declineRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('hi_requests')
        .doc(requestId)
        .update({
      'status': 'declined',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hi declined')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = localUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi Requests'),
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _requestsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load Hi requests.'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  return data['senderId'] == userId ||
                      data['receiverId'] == userId;
                }).toList();

                if (requests.isEmpty) {
                  return const Center(
                    child: Text('No Hi requests yet.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final doc = requests[index];
                    final data = doc.data();

                    final senderId = data['senderId']?.toString() ?? '';
                    final receiverId = data['receiverId']?.toString() ?? '';

                    final isReceived = receiverId == userId;
                    final isSent = senderId == userId;

                    final senderName =
                        data['senderNickname']?.toString() ?? 'Pulse';
                    final receiverName =
                        data['receiverNickname']?.toString() ?? 'Pulse';

                    final otherName = isReceived ? senderName : receiverName;
                    final status = (data['status'] ?? 'pending').toString();
                    final statusText = _statusText(data);
                    final expired = _isExpired(data);

                    return _HiRequestCard(
                      otherName: otherName,
                      status: status,
                      statusText: statusText,
                      isReceived: isReceived,
                      isSent: isSent,
                      expired: expired,
                      onAccept: isReceived && status == 'pending' && !expired
                          ? () => _acceptRequest(doc.id)
                          : null,
                      onDecline: isReceived && status == 'pending' && !expired
                          ? () => _declineRequest(doc.id)
                          : null,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _HiRequestCard extends StatelessWidget {
  const _HiRequestCard({
    required this.otherName,
    required this.status,
    required this.statusText,
    required this.isReceived,
    required this.isSent,
    required this.expired,
    required this.onAccept,
    required this.onDecline,
  });

  final String otherName;
  final String status;
  final String statusText;
  final bool isReceived;
  final bool isSent;
  final bool expired;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  Color _statusColor() {
    if (expired) return Colors.orange;

    switch (status) {
      case 'accepted':
        return AppColors.emerald;
      case 'declined':
        return AppColors.red;
      default:
        return AppColors.royalPurple;
    }
  }

  IconData _statusIcon() {
    if (expired) return Icons.hourglass_bottom_rounded;

    switch (status) {
      case 'accepted':
        return Icons.auto_awesome_rounded;
      case 'declined':
        return Icons.cancel_rounded;
      default:
        return Icons.waving_hand_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(_statusIcon(), color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(statusText),
                  const SizedBox(height: 4),
                  Text(
                    isReceived
                        ? 'Nearby Pulse wants to merge.'
                        : 'Waiting for nearby Pulse.',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
            ),
            if (onAccept != null || onDecline != null)
              Column(
                children: [
                  IconButton(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle_rounded),
                    color: AppColors.emerald,
                  ),
                  IconButton(
                    onPressed: onDecline,
                    icon: const Icon(Icons.cancel_rounded),
                    color: AppColors.red,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
