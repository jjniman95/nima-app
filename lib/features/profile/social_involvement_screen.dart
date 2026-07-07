import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class SocialInvolvementScreen extends StatefulWidget {
  const SocialInvolvementScreen({super.key});

  @override
  State<SocialInvolvementScreen> createState() =>
      _SocialInvolvementScreenState();
}

class _SocialInvolvementScreenState extends State<SocialInvolvementScreen> {
  final telegramController = TextEditingController();
  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final snapchatController = TextEditingController();
  final tiktokController = TextEditingController();
  final xController = TextEditingController();
  final linkedinController = TextEditingController();
  final emailController = TextEditingController();

  bool saving = false;

  @override
  void dispose() {
    telegramController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    snapchatController.dispose();
    tiktokController.dispose();
    xController.dispose();
    linkedinController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Map<String, String> _socialMap() {
    return {
      'telegram': telegramController.text.trim(),
      'instagram': instagramController.text.trim(),
      'facebook': facebookController.text.trim(),
      'snapchat': snapchatController.text.trim(),
      'tiktok': tiktokController.text.trim(),
      'xTwitter': xController.text.trim(),
      'linkedin': linkedinController.text.trim(),
      'email': emailController.text.trim(),
    }..removeWhere((key, value) => value.isEmpty);
  }

  Future<void> _createProfile() async {
    if (saving) return;

    setState(() => saving = true);

    final prefs = await SharedPreferences.getInstance();
    final localUserId = prefs.getString('localUserId');

    if (localUserId == null || localUserId.isEmpty) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile was not created correctly.')),
      );
      return;
    }

    final social = _socialMap();

    await FirebaseFirestore.instance.collection('users').doc(localUserId).set({
      'socialInvolvement': social,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await prefs.setBool('profileCompleted', true);

    if (!mounted) return;

    setState(() => saving = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;
    final background =
        isDark ? AppColors.darkBackground : const Color(0xFFF7F5FF);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Connect Beyond NIMA'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connect Beyond NIMA',
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
                      'These details remain private until you choose to share them.',
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
              const SizedBox(height: 28),
              _SocialField(
                controller: telegramController,
                label: 'Telegram',
                hint: 'Username',
                icon: FontAwesomeIcons.telegram,
              ),
              _SocialField(
                controller: instagramController,
                label: 'Instagram',
                hint: 'Username',
                icon: FontAwesomeIcons.instagram,
              ),
              _SocialField(
                controller: facebookController,
                label: 'Facebook',
                hint: 'Profile name or username',
                icon: FontAwesomeIcons.facebook,
              ),
              _SocialField(
                controller: snapchatController,
                label: 'Snapchat',
                hint: 'Username',
                icon: FontAwesomeIcons.snapchat,
              ),
              _SocialField(
                controller: tiktokController,
                label: 'TikTok',
                hint: 'Username',
                icon: FontAwesomeIcons.tiktok,
              ),
              _SocialField(
                controller: xController,
                label: 'X (Twitter)',
                hint: 'Username',
                icon: FontAwesomeIcons.xTwitter,
              ),
              _SocialField(
                controller: linkedinController,
                label: 'LinkedIn',
                hint: 'Public profile username',
                icon: FontAwesomeIcons.linkedin,
              ),
              _SocialField(
                controller: emailController,
                label: 'Email',
                hint: 'Email address',
                icon: FontAwesomeIcons.envelope,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: saving ? null : _createProfile,
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(
                    saving ? 'Creating...' : 'Create Profile',
                    style: const TextStyle(
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

class _SocialField extends StatelessWidget {
  const _SocialField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: AppColors.royalPurple,
            size: 21,
          ),
          filled: true,
          fillColor:
              isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.royalPurple,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
