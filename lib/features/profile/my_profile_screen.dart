import 'dart:convert';
import 'dart:io';

import 'social_involment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final nicknameController = TextEditingController();
  final bioController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  String? localUserId;
  String? profileImagePath;

  int age = 25;
  String gender = 'Prefer not to say';
  bool ghostMode = false;
  bool saving = false;

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
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nicknameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('localUserId');

    if (id == null || id.isEmpty) return;

    localUserId = id;

    nicknameController.text = prefs.getString('localNickname') ?? '';
    bioController.text = prefs.getString('localBio') ?? '';
    profileImagePath = prefs.getString('localProfileImagePath');

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();

    if (doc.exists) {
      final data = doc.data() ?? {};

      nicknameController.text =
          (data['nickname'] ?? nicknameController.text).toString();
      bioController.text = (data['bio'] ?? bioController.text).toString();
      age = data['age'] is int ? data['age'] : age;
      gender = (data['gender'] ?? gender).toString();
      ghostMode = data['ghostMode'] == true;

      final rawInterests = data['interests'];
      if (rawInterests is List) {
        selected
          ..clear()
          ..addAll(rawInterests.map((e) => e.toString()));
      }

      final imagePath = data['profileImagePath'];
      if (imagePath != null && imagePath.toString().isNotEmpty) {
        profileImagePath = imagePath.toString();
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openPhotoMenu() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_rounded),
                  title: const Text('View Profile Picture'),
                  onTap: () {
                    Navigator.pop(context);
                    _viewProfilePicture();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Take New Photo'),
                  subtitle: const Text('Front camera only'),
                  onTap: () {
                    Navigator.pop(context);
                    _takeNewPhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _viewProfilePicture() {
    final path = profileImagePath;

    if (path == null || path.isEmpty || !File(path).existsSync()) {
      _showSnack('No profile picture yet.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ProfilePictureView(imagePath: path),
      ),
    );
  }

  Future<void> _takeNewPhoto() async {
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 65,
      maxWidth: 512,
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

  Future<String> _profileThumbBase64(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _saveProfile() async {
    final nickname = nicknameController.text.trim();
    final bio = bioController.text.trim();

    if (profileImagePath == null || profileImagePath!.isEmpty) {
      _showSnack('Please take a profile picture.');
      return;
    }

    if (!File(profileImagePath!).existsSync()) {
      _showSnack('Profile picture file not found. Please take a new photo.');
      return;
    }

    if (nickname.isEmpty) {
      _showSnack('Please enter a nickname.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    var id = localUserId ?? prefs.getString('localUserId');
    if (id == null || id.isEmpty) {
      id = 'local_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('localUserId', id);
    }

    setState(() => saving = true);

    final profileThumbBase64 = await _profileThumbBase64(profileImagePath!);

    await FirebaseFirestore.instance.collection('users').doc(id).set({
      'uid': id,
      'nickname': nickname,
      'bio': bio,
      'age': age,
      'gender': gender,
      'interests': selected.toList(),
      'ghostMode': ghostMode,

      // Ghost Mode now controls Nearby visibility.
      // OFF = visible, ON = hidden from Nearby.
      'visibility': !ghostMode,

      'profileImagePath': profileImagePath,
      'profileThumbBase64': profileThumbBase64,
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await prefs.setString('localNickname', nickname);
    await prefs.setString('localBio', bio);
    await prefs.setString('localProfileImagePath', profileImagePath!);
    await prefs.setString('localProfileThumbBase64', profileThumbBase64);
    await prefs.setBool('ghostMode', ghostMode);

    if (!mounted) return;

    setState(() => saving = false);
    _showSnack('Profile updated.');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: AppColors.royalPurple,
                      backgroundImage: ghostMode ? null : _profileImage,
                      child: _profileImage == null || ghostMode
                          ? Text(
                              nicknameController.text.trim().isNotEmpty
                                  ? nicknameController
                                      .text
                                      .trim()[0]
                                      .toUpperCase()
                                  : 'N',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : null,
                    ),
                    GestureDetector(
                      onTap: _openPhotoMenu,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.royalPurple,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBackground
                                : Colors.white,
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
                      onChanged: (_) => setState(() {}),
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
                    const Icon(
                      Icons.cake_rounded,
                      color: AppColors.royalPurple,
                    ),
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
                    Icons.visibility_off_rounded,
                    color: AppColors.royalPurple,
                  ),
                  title: const Text('Ghost Mode'),
                  subtitle: Text(
                    ghostMode
                        ? 'You are hidden from Nearby.'
                        : 'You are visible in Nearby.',
                    style: TextStyle(color: mutedColor),
                  ),
                  value: ghostMode,
                  onChanged: (value) => setState(() => ghostMode = value),
                ),
              ),
              const SizedBox(height: 16),

SizedBox(
  width: double.infinity,
  height: 52,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SocialInvolvementScreen(),
        ),
      );
    },
    icon: const Icon(Icons.public_rounded),
    label: const Text('Connect Beyond NIMA'),
  ),
),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: saving ? null : _saveProfile,
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(saving ? 'Saving...' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePictureView extends StatelessWidget {
  const _ProfilePictureView({
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
      body: Center(
        child: Image.file(File(imagePath)),
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
        title: const Text('New Profile Picture'),
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
