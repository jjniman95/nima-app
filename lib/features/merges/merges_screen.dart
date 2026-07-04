import 'package:flutter/material.dart';

class MergesScreen extends StatefulWidget {
  const MergesScreen({super.key});

  @override
  State<MergesScreen> createState() => _MergesScreenState();
}

class _MergesScreenState extends State<MergesScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _MergesAppBar(),
      body: Center(
        child: Text('No active merges.'),
      ),
    );
  }
}

class _MergesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MergesAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Merges'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
