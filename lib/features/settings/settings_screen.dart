import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Edit Profile', Icons.person_rounded, null),
      ('Privacy', Icons.lock_rounded, null),
      ('Blocked Users', Icons.block_rounded, null),
      ('Report a Problem', Icons.report_rounded, null),
      ('About NIMA', Icons.info_rounded, null),
      ('Logout', Icons.logout_rounded, () => _logout(context)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final item = items[index];

          return Card(
            child: ListTile(
              leading: Icon(item.$2),
              title: Text(item.$1),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: item.$3,
            ),
          );
        },
      ),
    );
  }
}
