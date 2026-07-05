import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final ImagePicker picker = ImagePicker();

  String? profileImagePath;

  int age = 25;
  String gender = 'Prefer not to say';
  bool locationAllowed = false;
  bool visible = true;

  final interests = [
    '☕ Coffee',
    '🎵 Music',
    '🍕 Food',
    '✈️ Travel',
    '🎬 Movies',
    '📚 Books',
    '💪 Fitness',
    '🎮 Gaming',
  ];

  final selected = <String>{};

  @override
  void dispose() {
    nicknameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _takeProfilePhoto() async {
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (photo == null) return;

    if (!mounted) return;

    final usePhoto = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _PhotoPreviewScreen(imagePath: photo.path),
      ),
    );

    if (usePhoto == true) {
      setState(() {
        profileImagePath = photo.path;
      });
    }
  }

  Future<void> _continue() async {
    final nickname = nicknameController.text.trim();
    final bio = bioController.text.trim();

    if (profileImagePath == null || profileImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a profile picture.')),
      );
      return;
    }

    if (!File(profileImagePath!).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture not found. Please retake it.')),
      );
      return;
    }

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a nickname.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    var localUserId = prefs.getString('localUserId');

    if (localUserId == null || localUserId.isEmpty) {
      localUserId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('localUserId', localUserId);
    }

    await FirebaseFirestore.instance.collection('users').doc(localUserId).set({
      'uid': localUserId,
      'nickname': nickname,
      'bio': bio,
      'age': age,
      'gender': gender,
      'interests': selected.toList(),
      'locationAllowed': locationAllowed,
      'visibility': visible,
      'ghostMode': false,
      'profileImagePath': profileImagePath,
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await prefs.setBool('profileCompleted', true);
    await prefs.setString('localNickname', nickname);
    await prefs.setString('localBio', bio);
    await prefs.setString('localProfileImagePath', profileImagePath!);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  ImageProvider? get _profileImage {
    final path = profileImagePath;
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 59,
                          backgroundColor: AppColors.royalPurple,
                          backgroundImage: _profileImage,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 66,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        GestureDetector(
                          onTap: _takeProfilePhoto,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.royalPurple,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.darkBackground : Colors.white,
                                width: 4,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Create Your Profile',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Take a selfie and choose a nickname',
                      style: TextStyle(color: mutedColor, fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _takeProfilePhoto,
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(
                        profileImagePath == null
                            ? 'Take Profile Picture'
                            : 'Retake Profile Picture',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              _SectionCard(
                color: cardColor,
                child: Column(
                  children: [
                    TextField(
                      controller: nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Nickname *',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Tell something about yourself...',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _SectionTitle(title: 'Age', color: textColor),
              _SectionCard(
                color: cardColor,
                child: Row(
                  children: [
                    const Icon(Icons.cake_rounded, color: AppColors.royalPurple),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Slider(
                        value: age.toDouble(),
                        min: 18,
                        max: 70,
                        divisions: 52,
                        label: age.toString(),
                        onChanged: (value) {
                          setState(() => age = value.round());
                        },
                      ),
                    ),
                    Text(
                      '$age',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _SectionTitle(title: 'Gender', color: textColor),
              _SectionCard(
                color: cardColor,
                child: Column(
                  children: [
                    _GenderTile(
                      title: 'Male',
                      value: 'Male',
                      groupValue: gender,
                      onChanged: (v) => setState(() => gender = v),
                    ),
                    _GenderTile(
                      title: 'Female',
                      value: 'Female',
                      groupValue: gender,
                      onChanged: (v) => setState(() => gender = v),
                    ),
                    _GenderTile(
                      title: 'Prefer not to say',
                      value: 'Prefer not to say',
                      groupValue: gender,
                      onChanged: (v) => setState(() => gender = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _SectionTitle(title: 'Interests', color: textColor),
              _SectionCard(
                color: cardColor,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
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
              ),

              const SizedBox(height: 16),

              _SectionCard(
                color: cardColor,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.royalPurple,
                  ),
                  title: const Text('Allow Location'),
                  subtitle: Text(
                    'Used later to show nearby users.',
                    style: TextStyle(color: mutedColor),
                  ),
                  value: locationAllowed,
                  onChanged: (value) {
                    setState(() => locationAllowed = value);
                  },
                ),
              ),

              const SizedBox(height: 12),

              _SectionCard(
                color: cardColor,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(
                    Icons.visibility_rounded,
                    color: AppColors.royalPurple,
                  ),
                  title: const Text('Visible to Nearby Users'),
                  subtitle: Text(
                    'You can hide anytime.',
                    style: TextStyle(color: mutedColor),
                  ),
                  value: visible,
                  onChanged: (value) {
                    setState(() => visible = value);
                  },
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _continue,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreviewScreen extends StatelessWidget {
  const _PhotoPreviewScreen({
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile Picture'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(File(imagePath)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Use Photo'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.color,
  });

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    required this.color,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.transparent,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: child,
    );
  }
}

class _GenderTile extends StatelessWidget {
  const _GenderTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
