import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _goLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Privacy First', 'You decide when you are visible.'),
      ('Consent Always', 'Chats begin only after mutual acceptance.'),
      ('Connect Nearby', 'Discover people around you respectfully.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text(AppText.appName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 18),
            const Text(
              'Meet. Chat. Connect.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'A safe and private way to connect with nearby people through mutual consent.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 34),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    tileColor: Colors.white,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.royalPurple,
                      child: Icon(Icons.verified_user, color: Colors.white),
                    ),
                    title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.$2),
                  ),
                )),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _goLogin(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
