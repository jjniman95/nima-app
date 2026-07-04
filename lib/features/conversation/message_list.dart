import 'package:flutter/material.dart';

import '../../core/widgets/nima_message_bubble.dart';
import '../../models/pulse_message.dart';

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.controller,
    required this.messages,
    required this.currentPulseId,
  });

  final ScrollController controller;
  final List<PulseMessage> messages;
  final String currentPulseId;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Say something before the merge expires.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final mine = message.senderId == currentPulseId;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 180 + (index * 20)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: child,
              ),
            );
          },
          child: NimaMessageBubble(
            text: message.text,
            mine: mine,
            time: message.sentAtLabel.isEmpty ? 'Now' : message.sentAtLabel,
            seen: message.seen,
          ),
        );
      },
    );
  }
}
