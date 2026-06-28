import 'package:flutter/material.dart';

class HiRequestsScreen extends StatelessWidget {
  const HiRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _HiAppBar(),
      body: Center(
        child: Text('Hi request system will be added next.'),
      ),
    );
  }
}

class _HiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HiAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Hi Requests'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
