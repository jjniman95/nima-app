import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      ('Ava', 'Hi! Nice to meet you 👋'),
      ('You', 'Hello! Good to meet you too.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Private Chat')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text('Demo chat. Auto-disconnect and premium rules will be added later.'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: messages.map((item) {
                  final mine = item.$1 == 'You';
                  return Align(
                    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: mine ? AppColors.royalPurple : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(item.$2,
                          style: TextStyle(color: mine ? Colors.white : Colors.black87)),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(decoration: InputDecoration(hintText: 'Type a message...')),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: () {}, icon: const Icon(Icons.send_rounded)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
