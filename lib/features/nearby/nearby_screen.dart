import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      ('Ava', 'Coffee • Travel'),
      ('Emma', 'Music • Movies'),
      ('Noah', 'Books • Fitness'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.royalPurple.withOpacity(0.28),
                    AppColors.royalPurple.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.royalPurple,
                  child: Text('Me', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('People nearby',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            ...users.map((user) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(user.$1[0])),
                    title: Text(user.$1),
                    subtitle: Text(user.$2),
                    trailing: FilledButton(onPressed: () {}, child: const Text('Say Hi')),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
