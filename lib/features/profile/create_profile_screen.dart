import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final nicknameController = TextEditingController();
  final bioController = TextEditingController();
  final interests = ['Coffee', 'Travel', 'Music', 'Movies', 'Books', 'Fitness'];
  final selected = <String>{};

  bool saving = false;

  @override
  void dispose() {
    nicknameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
  if (nicknameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a nickname.')),
    );
    return;
  }

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.royalPurple,
                child: Icon(Icons.person_rounded, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'Nickname'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Short bio'),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Interests',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: interests.map((interest) {
                  final active = selected.contains(interest);
                  return FilterChip(
                    selected: active,
                    label: Text(interest),
                    onSelected: (_) {
                      setState(() {
                        active
                            ? selected.remove(interest)
                            : selected.add(interest);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 34),
              ElevatedButton(
                onPressed: saving ? null : _saveProfile,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text('Complete Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
