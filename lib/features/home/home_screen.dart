import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/hi_request.dart';
import '../../services/firebase_pulse_service.dart';
import '../../services/pulse_service.dart';
import '../chat/chats_screen.dart';
import '../hi_requests/hi_requests_screen.dart';
import '../hi_requests/merging_pulses_screen.dart';
import '../nearby/nearby_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';

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
  bool dialogOpen = false;

  final pages = const [
    NearbyScreen(),
    HiRequestsScreen(),
    ChatsScreen(),
    NotificationsScreen(),
    SettingsScreen(),
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
        if (handledRequests.contains(request.id)) continue;

        final isIncoming =
            request.receiverId == id && request.status == 'pending';

        final isAcceptedByOther =
            request.senderId == id &&
            request.status == 'accepted' &&
            request.conversationId != null &&
            request.conversationId!.isNotEmpty;

        if (isIncoming) {
          _showIncomingHi(request);
          break;
        }

        if (isAcceptedByOther) {
          handledRequests.add(request.id);

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
                await pulseService.declineHi(requestId: request.id);

                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Decline'),
            ),
            FilledButton(
              onPressed: () async {
                final conversationId =
                    await pulseService.acceptHi(request: request);

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
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );

    dialogOpen = false;
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
        onDestinationSelected: (value) => setState(() => currentIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radar_rounded),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(Icons.waving_hand_rounded),
            label: 'Hi',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
