import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../models/hi_request.dart';
import '../../services/firebase_pulse_service.dart';
import '../../services/pulse_service.dart';
import 'merging_pulses_screen.dart';

class HiRequestsScreen extends StatefulWidget {
  const HiRequestsScreen({super.key});

  @override
  State<HiRequestsScreen> createState() => _HiRequestsScreenState();
}

class _HiRequestsScreenState extends State<HiRequestsScreen> {
  String? localUserId;

  final PulseService pulseService = FirebasePulseService.instance;

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

  String _otherPulseName(HiRequest request) {
    if (request.receiverId == localUserId) {
      return request.senderNickname;
    }

    return request.receiverNickname;
  }

  bool _isReceived(HiRequest request) {
    return request.receiverId == localUserId;
  }

  String _statusText(HiRequest request, bool isReceived) {
    switch (request.status) {
      case 'accepted':
        return 'Pulses Merged';
      case 'declined':
        return 'Hi Declined';
      case 'expired':
        return 'Merge Expired';
      default:
        return isReceived ? 'Incoming Hi' : 'Outgoing Hi';
    }
  }

  Future<void> _acceptRequest(HiRequest request) async {
    try {
      final conversationId = await pulseService.acceptHi(request: request);

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MergingPulsesScreen(
            conversationId: conversationId,
            otherPulseName: _otherPulseName(request),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not merge Pulses. Please try again.'),
        ),
      );
    }
  }

  Future<void> _declineRequest(HiRequest request) async {
    try {
      await pulseService.declineHi(requestId: request.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hi declined')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not decline Hi. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = localUserId;

    return Scaffold(
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<HiRequest>>(
              stream: pulseService.streamHiRequests(userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load Hi requests.'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = snapshot.data!;

                if (requests.isEmpty) {
                  return const _EmptyHiRequestsView();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];

                    final isReceived = _isReceived(request);
                    final otherName = _otherPulseName(request);
                    final statusText = _statusText(request, isReceived);
                    final expired = request.status == 'expired';

                    return _HiRequestCard(
                      otherName: otherName,
                      status: request.status,
                      statusText: statusText,
                      isReceived: isReceived,
                      isSent: !isReceived,
                      expired: expired,
                      onAccept: isReceived && request.isPending && !expired
                          ? () => _acceptRequest(request)
                          : null,
                      onDecline: isReceived && request.isPending && !expired
                          ? () => _declineRequest(request)
                          : null,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _EmptyHiRequestsView extends StatefulWidget {
  const _EmptyHiRequestsView();

  @override
  State<_EmptyHiRequestsView> createState() => _EmptyHiRequestsViewState();
}

class _EmptyHiRequestsViewState extends State<_EmptyHiRequestsView>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    scale = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
            ScaleTransition(
              scale: scale,
              child: CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.royalPurple.withOpacity(0.14),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  color: AppColors.royalPurple,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Hi requests',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nearby Pulses who say Hi will appear here.',
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
        return isReceived ? AppColors.royalPurple : Colors.blueGrey;
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
        return isReceived
            ? Icons.waving_hand_rounded
            : Icons.north_east_rounded;
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
