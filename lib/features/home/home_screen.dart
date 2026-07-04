import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../models/hi_request.dart';
import '../../services/firebase_pulse_service.dart';
import '../../services/pulse_service.dart';
import '../hi_requests/hi_requests_screen.dart';
import '../hi_requests/merging_pulses_screen.dart';
import '../merges/merges_screen.dart';
import '../nearby/nearby_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final PulseService pulseService = FirebasePulseService.instance;

  String? localUserId;
  StreamSubscription<List<HiRequest>>? hiSub;

  final Set<String> handledRequests = {};
  final Map<String, DateTime> silencedSenders = {};

  bool dialogOpen = false;
  bool hiBadge = false;
  bool mergesBadge = false;

  final pages = const [
    NearbyScreen(),
    HiRequestsScreen(),
    MergesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAndListen();
  }

  Future<void> _loadUserAndListen() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('localUserId');

    if (id == null || id.isEmpty) return;

    localUserId = id;

    hiSub = pulseService.streamHiRequests(id).listen((requests) {
      for (final request in requests) {
        final isIncoming =
            request.receiverId == id && request.status == 'pending';

        final isAcceptedByOther =
            request.senderId == id &&
            request.status == 'accepted' &&
            request.conversationId != null &&
            request.conversationId!.isNotEmpty;

        if (isIncoming) {
          if (currentIndex != 1 && mounted) {
            setState(() => hiBadge = true);
          }

          if (!handledRequests.contains(request.id) &&
              !_isSenderSilenced(request.senderId)) {
            _showIncomingHi(request);
            break;
          }
        }

        if (isAcceptedByOther && !handledRequests.contains(request.id)) {
          handledRequests.add(request.id);

          if (mounted) {
            setState(() => mergesBadge = true);
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MergingPulsesScreen(
                conversationId: request.conversationId!,
                otherPulseName: request.receiverNickname,
              ),
            ),
          );

          break;
        }
      }
    });
  }

  bool _isSenderSilenced(String senderId) {
    final until = silencedSenders[senderId];
    if (until == null) return false;

    if (DateTime.now().isAfter(until)) {
      silencedSenders.remove(senderId);
      return false;
    }

    return true;
  }

  Future<void> _ghostAccept(HiRequest request) async {
    final prefs = await SharedPreferences.getInstance();

    final hidden = prefs.getStringList('hidePhotoFromPulseIds') ?? [];

    if (!hidden.contains(request.senderId)) {
      hidden.add(request.senderId);
      await prefs.setStringList('hidePhotoFromPulseIds', hidden);
    }

    final conversationId = await pulseService.acceptHi(request: request);

    if (!mounted) return;

    Navigator.pop(context);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MergingPulsesScreen(
          conversationId: conversationId,
          otherPulseName: request.senderNickname,
        ),
      ),
    );
  }

  Future<void> _accept(HiRequest request) async {
    final conversationId = await pulseService.acceptHi(request: request);

    if (!mounted) return;

    Navigator.pop(context);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MergingPulsesScreen(
          conversationId: conversationId,
          otherPulseName: request.senderNickname,
        ),
      ),
    );
  }

  Future<void> _showIncomingHi(HiRequest request) async {
    if (dialogOpen || !mounted) return;

    dialogOpen = true;
    handledRequests.add(request.id);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Incoming Hi 👋'),
          content: Text('${request.senderNickname} says Hi.'),
          actions: [
            TextButton(
              onPressed: () async {
                silencedSenders[request.senderId] =
                    DateTime.now().add(const Duration(minutes: 5));

                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Silent 5 min'),
            ),
            TextButton(
              onPressed: () async {
                await pulseService.declineHi(requestId: request.id);

                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Decline'),
            ),
            TextButton(
              onPressed: () => _ghostAccept(request),
              child: const Text('Ghost Accept'),
            ),
            FilledButton(
              onPressed: () => _accept(request),
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );

    dialogOpen = false;
  }

  void _changeTab(int value) {
    setState(() {
      currentIndex = value;

      if (value == 1) hiBadge = false;
      if (value == 2) mergesBadge = false;
    });
  }

  @override
  void dispose() {
    hiSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _changeTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.radar_rounded),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: _NavIconWithDot(
              icon: Icons.waving_hand_rounded,
              showDot: hiBadge,
            ),
            label: 'Hi',
          ),
          NavigationDestination(
            icon: _NavIconWithDot(
              icon: Icons.auto_awesome_rounded,
              showDot: mergesBadge,
            ),
            label: 'Merges',
          ),
        ],
      ),
    );
  }
}

class _NavIconWithDot extends StatelessWidget {
  const _NavIconWithDot({
    required this.icon,
    required this.showDot,
  });

  final IconData icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (showDot)
          Positioned(
            right: -3,
            top: -3,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.royalPurple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.royalPurple.withOpacity(0.55),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
