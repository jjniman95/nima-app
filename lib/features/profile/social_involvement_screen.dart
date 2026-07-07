import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/widgets/nima_svg_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class SocialInvolvementScreen extends StatefulWidget {
  const SocialInvolvementScreen({
    super.key,
    this.sharingMode = false,
    this.finishToHome = true,
  });

  final bool sharingMode;
  final bool finishToHome;

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

  bool loading = true;
  bool saving = false;

  String? localUserId;
  Map<String, String> currentSocials = {};
  final selectedKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _loadSocialDetails();
  }

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

  Future<void> _loadSocialDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('localUserId');

    if (id == null || id.isEmpty) {
      if (!mounted) return;
      setState(() => loading = false);
      return;
    }

    localUserId = id;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();

    final data = doc.data() ?? {};
    final rawSocials = Map<String, dynamic>.from(
      data['socialInvolvement'] ?? {},
    );

    currentSocials = rawSocials.map(
      (key, value) => MapEntry(key, value.toString()),
    )..removeWhere((key, value) => value.trim().isEmpty);

    telegramController.text = currentSocials['telegram'] ?? '';
    instagramController.text = currentSocials['instagram'] ?? '';
    facebookController.text = currentSocials['facebook'] ?? '';
    snapchatController.text = currentSocials['snapchat'] ?? '';
    tiktokController.text = currentSocials['tiktok'] ?? '';
    xController.text = currentSocials['xTwitter'] ?? '';
    linkedinController.text = currentSocials['linkedin'] ?? '';
    emailController.text = currentSocials['email'] ?? '';

    if (!mounted) return;
    setState(() => loading = false);
  }

  Map<String, String> _socialMapFromFields() {
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

  Future<void> _saveSocialDetails() async {
    if (saving) return;

    final id = localUserId;
    if (id == null || id.isEmpty) {
      _showSnack('Profile was not created correctly.');
      return;
    }

    setState(() => saving = true);

    final social = _socialMapFromFields();

    await FirebaseFirestore.instance.collection('users').doc(id).set({
      'socialInvolvement': social,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profileCompleted', true);

    if (!mounted) return;
    setState(() => saving = false);

    if (widget.finishToHome) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _shareSelected() {
    if (selectedKeys.isEmpty) {
      _showSnack('Select at least one detail to share.');
      return;
    }

    final selectedSocials = <String, dynamic>{};

    for (final key in selectedKeys) {
      final value = currentSocials[key];
      if (value != null && value.trim().isNotEmpty) {
        selectedSocials[_displayName(key)] = value.trim();
      }
    }

    if (selectedSocials.isEmpty) {
      _showSnack('No selected details found.');
      return;
    }

    Navigator.pop(context, selectedSocials);
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _displayName(String key) {
    switch (key) {
      case 'telegram':
        return 'Telegram';
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'snapchat':
        return 'Snapchat';
      case 'tiktok':
        return 'TikTok';
      case 'xTwitter':
        return 'X (Twitter)';
      case 'linkedin':
        return 'LinkedIn';
      case 'email':
        return 'Email';
      default:
        return key;
    }
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'telegram':
        return FontAwesomeIcons.telegram;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'snapchat':
        return FontAwesomeIcons.snapchat;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'xTwitter':
        return FontAwesomeIcons.xTwitter;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'email':
        return FontAwesomeIcons.envelope;
      default:
        return Icons.public_rounded;
    }
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
        title: Text(
          widget.sharingMode
              ? 'Share Contact Methods'
              : 'Connect Beyond NIMA',
        ),
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
                      widget.sharingMode
                          ? 'Share with this Pulse'
                          : 'Connect Beyond NIMA',
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
                            widget.sharingMode
                                ? 'Choose which contact methods to share for this Merge only.'
                                : 'These details remain private until you choose to share them.',
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
                    if (widget.sharingMode)
                      _SharingContent(
                        socials: currentSocials,
                        selectedKeys: selectedKeys,
                        displayName: _displayName,
                        iconFor: _iconFor,
                        onChanged: (key, value) {
                          setState(() {
                            value
                                ? selectedKeys.add(key)
                                : selectedKeys.remove(key);
                          });
                        },
                      )
                    else
                      _EditingContent(
                        telegramController: telegramController,
                        instagramController: instagramController,
                        facebookController: facebookController,
                        snapchatController: snapchatController,
                        tiktokController: tiktokController,
                        xController: xController,
                        linkedinController: linkedinController,
                        emailController: emailController,
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: saving
                            ? null
                            : widget.sharingMode
                                ? _shareSelected
                                : _saveSocialDetails,
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                widget.sharingMode
                                    ? Icons.ios_share_rounded
                                    : Icons.check_circle_rounded,
                              ),
                        label: Text(
                          widget.sharingMode
                              ? 'Share Selected'
                              : saving
                                  ? 'Saving...'
                                  : 'Create Profile',
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

class _SharingContent extends StatelessWidget {
  const _SharingContent({
    required this.socials,
    required this.selectedKeys,
    required this.displayName,
    required this.iconFor,
    required this.onChanged,
  });

  final Map<String, String> socials;
  final Set<String> selectedKeys;
  final String Function(String key) displayName;
  final IconData Function(String key) iconFor;
  final void Function(String key, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    if (socials.isEmpty) {
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
          'No Connect Beyond NIMA details added yet.',
          style: TextStyle(
            color: mutedColor,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      children: socials.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;

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
            value: selectedKeys.contains(key),
            onChanged: (value) => onChanged(key, value ?? false),
            activeColor: AppColors.royalPurple,
            secondary: Icon(
              iconFor(key),
              color: AppColors.royalPurple,
              size: 23,
            ),
            title: Text(
              displayName(key),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(value),
          ),
        );
      }).toList(),
    );
  }
}

class _EditingContent extends StatelessWidget {
  const _EditingContent({
    required this.telegramController,
    required this.instagramController,
    required this.facebookController,
    required this.snapchatController,
    required this.tiktokController,
    required this.xController,
    required this.linkedinController,
    required this.emailController,
  });

  final TextEditingController telegramController;
  final TextEditingController instagramController;
  final TextEditingController facebookController;
  final TextEditingController snapchatController;
  final TextEditingController tiktokController;
  final TextEditingController xController;
  final TextEditingController linkedinController;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialField(
          controller: telegramController,
          label: 'Telegram',
          hint: 'Username',
          const NimaSvgIcon(name: 'telegram')
          ),
        _SocialField(
          controller: instagramController,
          label: 'Instagram',
          hint: 'Username',
          const NimaSvgIcon(name: 'instagram')
        ),
        _SocialField(
          controller: facebookController,
          label: 'Facebook',
          hint: 'Profile name or username',
          const NimaSvgIcon(name: 'facebook')
        ),
        _SocialField(
          controller: snapchatController,
          label: 'Snapchat',
          hint: 'Username',
          const NimaSvgIcon(name: 'snapchat')
        ),
        _SocialField(
          controller: tiktokController,
          label: 'TikTok',
          hint: 'Username',
          const NimaSvgIcon(name: 'tiktok')
        ),
        _SocialField(
          controller: xController,
          label: 'X (Twitter)',
          hint: 'Username',
          const NimaSvgIcon(name: 'xtwitter')
        ),
        _SocialField(
          controller: linkedinController,
          label: 'LinkedIn',
          hint: 'Public profile username',
          const NimaSvgIcon(name: 'linkedin')
        ),
        _SocialField(
          controller: emailController,
          label: 'Email',
          hint: 'Email address',
          const NimaSvgIcon(name: 'email')
          keyboardType: TextInputType.emailAddress,
        ),
      ],
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
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
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
