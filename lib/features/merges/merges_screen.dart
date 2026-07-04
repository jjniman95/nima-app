import 'package:flutter/material.dart';

class MergesScreen extends StatefulWidget {
  const MergesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _ChatAppBar(),
      body: Center(
        child: Text('Unlimited chat will be added after Hi Requests.'),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Chats'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
