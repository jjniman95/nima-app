import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';

class AboutPulseScreen extends StatefulWidget {
  const AboutPulseScreen({super.key});

  @override
  State<AboutPulseScreen> createState() => _AboutPulseScreenState();
}

class _AboutPulseScreenState extends State<AboutPulseScreen> {
  bool loading = true;

  String nickname = '';
  String bio = '';
  String age = '';
  String gender = '';
  List<String> interests = [];
  String profileThumbBase64 = '';

  final selectedKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final loadedNickname = prefs.getString('localNickname') ?? '';
    final loadedBio = prefs.getString('localBio') ?? '';
    final loadedAge = prefs.getString('localAge') ?? '';
    final loadedGender = prefs.getString('localGender') ?? '';
    final loadedInterests = prefs.getStringList('localInterests') ?? [];
    final loadedThumb = prefs.getString('localProfileThumbBase64') ?? '';

    if (!mounted) return;

    setState(() {
      nickname = loadedNickname;
      bio = loadedBio;
      age = loadedAge;
      gender = loadedGender;
      interests = loadedInterests;
      profileThumbBase64 = loadedThumb;

      if (profileThumbBase64.isNotEmpty) selectedKeys.add('profilePicture');
      if (nickname.isNotEmpty) selectedKeys.add('nickname');
      if (bio.isNotEmpty) selectedKeys.add('bio');
      if (age.isNotEmpty) selectedKeys.add('age');
      if (gender.isNotEmpty) selectedKeys.add('gender');
      if (interests.isNotEmpty) selectedKeys.add('interests');

      loading = false;
    });
  }

  Uint8List? get _profileBytes {
    if (profileThumbBase64.isEmpty) return null;

    try {
      return base64Decode(profileThumbBase64);
    } catch (_) {
      return null;
    }
  }

  bool _hasValue(String key) {
    switch (key) {
      case 'profilePicture':
        return profileThumbBase64.isNotEmpty;
      case 'nickname':
        return nickname.isNotEmpty;
      case 'bio':
        return bio.isNotEmpty;
      case 'age':
        return age.isNotEmpty;
      case 'gender':
        return gender.isNotEmpty;
      case 'interests':
        return interests.isNotEmpty;
      default:
        return false;
    }
  }

  String _displayValue(String key) {
    switch (key) {
      case 'profilePicture':
        return 'Profile photo';
      case 'nickname':
        return nickname;
      case 'bio':
        return bio;
      case 'age':
        return age;
      case 'gender':
        return gender;
      case 'interests':
        return interests.join(' • ');
      default:
        return '';
    }
  }

  String _displayName(String key) {
    switch (key) {
      case 'profilePicture':
        return 'Profile Picture';
      case 'nickname':
        return 'Nickname';
      case 'bio':
        return 'Bio';
      case 'age':
        return 'Age';
      case 'gender':
        return 'Gender';
      case 'interests':
        return 'Interests';
      default:
        return key;
    }
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'profilePicture':
        return Icons.account_circle_rounded;
      case 'nickname':
        return Icons.badge_rounded;
      case 'bio':
        return Icons.edit_note_rounded;
      case 'age':
        return Icons.cake_rounded;
      case 'gender':
        return Icons.person_rounded;
      case 'interests':
        return Icons.favorite_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  void _shareSelected() {
    if (selectedKeys.isEmpty) {
      _showSnack('Select at least one profile detail to share.');
      return;
    }

    final selectedDetails = <String, dynamic>{};

    for (final key in selectedKeys) {
      if (!_hasValue(key)) continue;

      switch (key) {
        case 'profilePicture':
          selectedDetails['Profile Picture'] = profileThumbBase64;
          break;
        case 'nickname':
          selectedDetails['Nickname'] = nickname;
          break;
        case 'bio':
          selectedDetails['Bio'] = bio;
          break;
        case 'age':
          selectedDetails['Age'] = age;
          break;
        case 'gender':
          selectedDetails['Gender'] = gender;
          break;
        case 'interests':
          selectedDetails['Interests'] = interests;
          break;
      }
    }

    if (selectedDetails.isEmpty) {
      _showSnack('No selected profile details found.');
      return;
    }

    Navigator.pop(context, selectedDetails);
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : const Color(0xFFF7F5FF);
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    final shareKeys = [
      'profilePicture',
      'nickname',
      'bio',
      'age',
      'gender',
      'interests',
    ].where(_hasValue).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('About Pulse'),
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share About Pulse',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 31,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          color: AppColors.royalPurple,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Choose which profile details to share for this Merge only.',
                            style: TextStyle(
                              color: mutedColor,
                              height: 1.4,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    if (shareKeys.isEmpty)
                      _EmptyCard(isDark: isDark)
                    else ...[
                      Center(
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor:
                              AppColors.royalPurple.withOpacity(0.20),
                          backgroundImage: _profileBytes == null
                              ? null
                              : MemoryImage(_profileBytes!),
                          child: _profileBytes == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 56,
                                  color: AppColors.royalPurple,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ...shareKeys.map(
                        (key) => _ShareTile(
                          icon: _iconFor(key),
                          title: _displayName(key),
                          value: _displayValue(key),
                          selected: selectedKeys.contains(key),
                          onChanged: (value) {
                            setState(() {
                              value
                                  ? selectedKeys.add(key)
                                  : selectedKeys.remove(key);
                            });
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: shareKeys.isEmpty ? null : _shareSelected,
                        icon: const Icon(Icons.ios_share_rounded),
                        label: const Text(
                          'Share Selected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.selected,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black12,
        ),
      ),
      child: CheckboxListTile(
        value: selected,
        onChanged: (value) => onChanged(value ?? false),
        activeColor: AppColors.royalPurple,
        secondary: Icon(
          icon,
          color: AppColors.royalPurple,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          value,
          maxLines: title == 'Bio' ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: mutedColor,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black12,
        ),
      ),
      child: Text(
        'No profile details are available to share yet.',
        style: TextStyle(
          color: mutedColor,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
