import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Edit Profile', Icons.person_rounded),
      ('Privacy', Icons.lock_rounded),
      ('Blocked Users', Icons.block_rounded),
      ('Report a Problem', Icons.report_rounded),
      ('About NIMA', Icons.info_rounded),
      ('Logout', Icons.logout_rounded),
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
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
