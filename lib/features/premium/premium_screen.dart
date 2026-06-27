import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      'Unlimited chat time',
      'Unlimited messages',
      'Reconnect with mutual consent',
      'More privacy controls',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('NIMA Premium')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.workspace_premium_rounded, size: 84, color: AppColors.amber),
          const SizedBox(height: 20),
          const Text('Upgrade your connections',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          const Text(
            'Premium features will be connected after the free chat system is complete.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ...benefits.map((benefit) => Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_rounded, color: AppColors.emerald),
                  title: Text(benefit),
                ),
              )),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text('Coming Soon')),
        ],
      ),
    );
  }
}
