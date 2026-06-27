import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      'Someone said Hi 👋',
      'Your Hi request was accepted',
      'New message received',
      'Conversation ended',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(items[index]),
              subtitle: const Text('Just now'),
            ),
          );
        },
      ),
    );
  }
}
