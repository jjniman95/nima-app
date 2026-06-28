import 'package:flutter/material.dart';

import '../chat/chats_screen.dart';
import '../hi_requests/hi_requests_screen.dart';
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

  final pages = const [
    NearbyScreen(),
    HiRequestsScreen(),
    ChatsScreen(),
    NotificationsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (value) => setState(() => currentIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.radar_rounded), label: 'Nearby'),
          NavigationDestination(icon: Icon(Icons.waving_hand_rounded), label: 'Hi'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
