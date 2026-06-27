import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      'Unlimited chat time',
      'Unlimited messages',
      'Two-way reconnects',
      'Extra profile customization',
      'Voice messages in future',
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('NIMA Premium'),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              'NIMA Premium',
              style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Continue meaningful conversations without limits.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 26),
            ...benefits.map((b) => ListTile(
                  leading: const Icon(Icons.check_circle, color: AppColors.emerald),
                  title: Text(b, style: const TextStyle(color: Colors.white)),
                )),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Upgrade Later'),
            ),
          ],
        ),
      ),
    );
  }
}
