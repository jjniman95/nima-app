import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _NotificationsAppBar(),
      body: Center(
        child: Text('Notifications will be added later.'),
      ),
    );
  }
}

class _NotificationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _NotificationsAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Notifications'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
