import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/pulse_plus_sheet.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    required this.enabled,
    required this.onSend,
    this.onTyping,
    this.onAboutPulse,
    this.onSocialInvolvement,
  });

  final bool enabled;
  final Future<void> Function(String text) onSend;
  final Future<void> Function()? onTyping;

  final VoidCallback? onAboutPulse;
  final VoidCallback? onSocialInvolvement;
  
  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController controller = TextEditingController();

  bool sending = false;
  Timer? typingCooldown;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (mounted) setState(() {});
      _notifyTyping();
    });
  }

  @override
  void dispose() {
    typingCooldown?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _notifyTyping() {
    if (!widget.enabled) return;
    if (controller.text.trim().isEmpty) return;
    if (typingCooldown?.isActive == true) return;

    widget.onTyping?.call();
    typingCooldown = Timer(const Duration(seconds: 2), () {});
  }

  Future<void> _send() async {
    final text = controller.text.trim();

    if (text.isEmpty || sending || !widget.enabled) return;

    setState(() => sending = true);

    await widget.onSend(text);

    controller.clear();

    if (mounted) {
      setState(() => sending = false);
    }
  }

  void _showMoreActions() {
    if (!widget.enabled) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
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
                const SizedBox(height: 14),
                _ActionTile(
                  icon: Icons.mic_rounded,
                  title: 'Voice Message',
                  subtitle: 'Coming later with Pulse Plus',
                  onTap: () {
                    Navigator.pop(context);
                    _showPlus('Voice Messages', Icons.mic_rounded);
                  },
                ),
                _ActionTile(
                  icon: Icons.image_rounded,
                  title: 'Send Image',
                  subtitle: 'Coming later with Pulse Plus',
                  onTap: () {
                    Navigator.pop(context);
                    _showPlus('Send Image', Icons.image_rounded);
                  },
                ),
                _ActionTile(
                  icon: Icons.person_search_rounded,
                  title: 'About Pulse',
                  subtitle: 'Request selected profile details',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onAboutPulse?.call();
                  },
                ),
                _ActionTile(
                  icon: Icons.public_rounded,
                  title: 'Social Involvement',
                  subtitle: 'Request connection beyond NIMA',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSocialInvolvement?.call();
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEmojiPicker() {
    _showComingSoon('Emoji picker will be added later.');
  }

  void _showPlus(String feature, IconData icon) {
    showPulsePlusSheet(
      context,
      feature: feature,
      icon: icon,
    );
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSend = controller.text.trim().isNotEmpty && widget.enabled;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black12,
            ),
          ),
        ),
        child: Row(
          children: [
            _RoundInputButton(
              icon: Icons.add_rounded,
              enabled: widget.enabled,
              onTap: _showMoreActions,
            ),
            const SizedBox(width: 8),
            _RoundInputButton(
              icon: Icons.emoji_emotions_rounded,
              enabled: widget.enabled,
              onTap: _showEmojiPicker,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: widget.enabled ? 'Message...' : 'Merge expired',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : const Color(0xFFF2EEFA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              heroTag: 'send_message',
              backgroundColor: canSend ? AppColors.royalPurple : Colors.grey,
              onPressed: canSend ? _send : null,
              child: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundInputButton extends StatelessWidget {
  const _RoundInputButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.royalPurple : Colors.grey;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: CircleAvatar(
        radius: 21,
        backgroundColor: color.withOpacity(0.14),
        child: Icon(
          icon,
          color: color,
          size: 23,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.royalPurple.withOpacity(0.14),
        child: Icon(
          icon,
          color: AppColors.royalPurple,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: mutedColor),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: mutedColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
