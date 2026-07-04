import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/pulse_plus_sheet.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    required this.enabled,
    required this.onSend,
  });

  final bool enabled;
  final Future<void> Function(String text) onSend;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController controller = TextEditingController();
  bool sending = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

  void _showPlus(String feature, IconData icon) {
    showPulsePlusSheet(
      context,
      feature: feature,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSend = controller.text.trim().isNotEmpty && widget.enabled;
    final mutedColor = isDark ? Colors.white60 : AppColors.textMuted;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black12,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _PlusButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () => _showPlus('Camera', Icons.camera_alt_rounded),
                ),
                const SizedBox(width: 8),
                _PlusButton(
                  icon: Icons.mic_rounded,
                  label: 'Voice',
                  onTap: () => _showPlus('Voice Messages', Icons.mic_rounded),
                ),
                const SizedBox(width: 8),
                _PlusButton(
                  icon: Icons.emoji_emotions_rounded,
                  label: 'Reaction',
                  onTap: () => _showPlus(
                    'Message Reactions',
                    Icons.emoji_emotions_rounded,
                  ),
                ),
                const Spacer(),
                Text(
                  'Future Pulse Plus',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: widget.enabled,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          widget.enabled ? 'Message...' : 'Merge expired',
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFFF2EEFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton.small(
                  heroTag: 'send_message',
                  backgroundColor:
                      canSend ? AppColors.royalPurple : Colors.grey,
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
          ],
        ),
      ),
    );
  }
}

class _PlusButton extends StatelessWidget {
  const _PlusButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.royalPurple.withOpacity(0.12),
            child: Icon(icon, color: AppColors.royalPurple, size: 19),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: textColor),
          ),
        ],
      ),
    );
  }
}
