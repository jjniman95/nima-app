import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  void _finish(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interests = ['Travel', 'Music', 'Coffee', 'Movies', 'Books', 'Fitness'];

    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 46,
              child: Icon(Icons.person, size: 54),
            ),
            const SizedBox(height: 24),
            const TextField(decoration: InputDecoration(labelText: 'Nickname')),
            const SizedBox(height: 14),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Age'),
            ),
            const SizedBox(height: 14),
            const TextField(decoration: InputDecoration(labelText: 'Bio')),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Interests', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: interests.map((e) => Chip(label: Text(e))).toList(),
            ),
            const SizedBox(height: 34),
            ElevatedButton(
              onPressed: () => _finish(context),
              child: const Text('Complete Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
