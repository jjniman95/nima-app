import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AboutNimaScreen extends StatelessWidget {
  const AboutNimaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About NIMA'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.royalPurple.withOpacity(0.16),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.royalPurple,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'NIMA',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Meet nearby. Say Hi. Merge. Leave no history.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              _InfoCard(
                color: cardColor,
                icon: Icons.favorite_rounded,
                title: 'What is NIMA?',
                body:
                    'NIMA is a nearby-first social communication platform designed to help people connect with others who are physically nearby. Unlike traditional messaging apps, NIMA has no permanent friends, followers, contact lists, or endless chat history. Every connection begins with mutual consent and exists only for a limited time.',
              ),
              _InfoCard(
                color: cardColor,
                icon: Icons.lock_rounded,
                title: 'Privacy First',
                body:
                    'Privacy is the foundation of NIMA. Conversations are temporary, Merges expire automatically, and users always control when they are discoverable. Once a Merge ends, all messages from that Merge are permanently removed.',
              ),
              _SectionTitle(text: 'How to Operate NIMA', color: textColor),
              _StepCard(
                color: cardColor,
                number: '1',
                title: 'Create Your Pulse',
                body:
                    'Take a profile picture using your front camera, choose a nickname, and complete your profile.',
              ),
              _StepCard(
                color: cardColor,
                number: '2',
                title: 'Discover Nearby Pulses',
                body:
                    'Open the Nearby radar to discover other Pulses around you.',
              ),
              _StepCard(
                color: cardColor,
                number: '3',
                title: 'Send a Hi',
                body:
                    'Tap a nearby Pulse and send a Hi request. The other person can Accept, Ghost Accept, Decline, or stay Silent for 5 minutes.',
              ),
              _StepCard(
                color: cardColor,
                number: '4',
                title: 'Merge',
                body:
                    'When your Hi is accepted, both Pulses become Merged and can begin a private temporary conversation.',
              ),
              _StepCard(
                color: cardColor,
                number: '5',
                title: 'Disconnect or Expire',
                body:
                    'A Merge can end automatically when the timer expires, or either Pulse can disconnect it manually.',
              ),
              _SectionTitle(text: 'About the Timer', color: textColor),
              _InfoCard(
                color: cardColor,
                icon: Icons.timer_rounded,
                title: 'Merge Timer',
                body:
                    'Every Merge has a countdown timer. The timer resets whenever either Pulse sends a message or stays active in the conversation. If the timer reaches zero, the Merge expires automatically.',
              ),
              _InfoCard(
                color: cardColor,
                icon: Icons.delete_forever_rounded,
                title: 'When the Timer Ends',
                body:
                    'When a Merge expires or is disconnected, every message is permanently deleted, the Merge disappears, and both Pulses must send a new Hi if they want to connect again.',
              ),
              _SectionTitle(text: 'NIMA Vocabulary', color: textColor),
              _VocabularyCard(
                color: cardColor,
                word: 'Pulse',
                meaning: 'A NIMA user. Every person using NIMA is called a Pulse.',
              ),
              _VocabularyCard(
                color: cardColor,
                word: 'Nearby',
                meaning:
                    'The live radar area that discovers nearby Pulses available to connect.',
              ),
              _VocabularyCard(
                color: cardColor,
                word: 'Radar',
                meaning:
                    'The animated screen that displays nearby Pulses in real time.',
              ),
              _VocabularyCard(
                color: cardColor,
                word: 'Hi',
                meaning:
                    'A nearby connection request sent from one Pulse to another.',
              ),
              _VocabularyCard(
                color: cardColor,
                word: 'Ghost Accept',
                meaning:
                    'Accept a Hi while hiding your profile picture from that specific Pulse.',
              ),
              _VocabularyCard(
                color: cardColor,
                word: 'Merge',
                meaning:
                    'A temporary private connection between two Pulses.',
              ),
              _VocabularyCard(
                color: cardColor,
                word: 'Disconnect Merge',
                meaning:
                    'End a Merge manually before the timer expires. All messages from that Merge are permanently removed.',
              ),
              _VocabularyCard(
                color: cardColor,
                word: 'Ghost Mode',
                meaning:
                    'Become invisible on Nearby. While Ghost Mode is enabled, other Pulses cannot discover you or send you new Hi requests.',
              ),
              _VocabularyCard(
                color: cardColor,
                word: 'Temporary Conversation',
                meaning:
                    'Messages exchanged during an active Merge. They disappear when the Merge expires or is disconnected.',
              ),
              _SectionTitle(text: 'NIMA Privacy Rules', color: textColor),
              _BulletCard(
                color: cardColor,
                items: const [
                  'No permanent chat history.',
                  'No friend requests.',
                  'No followers.',
                  'No permanent contacts.',
                  'No usernames to search.',
                  'Nearby discovery only.',
                  'Every Merge begins with mutual consent.',
                  'Ghost Mode lets you disappear from Nearby.',
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Version 0.1',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      color: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBubble(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: _TitleBody(title: title, body: body),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.color,
    required this.number,
    required this.title,
    required this.body,
  });

  final Color color;
  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      color: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.royalPurple,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _TitleBody(title: title, body: body),
          ),
        ],
      ),
    );
  }
}

class _VocabularyCard extends StatelessWidget {
  const _VocabularyCard({
    required this.color,
    required this.word,
    required this.meaning,
  });

  final Color color;
  final String word;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      color: color,
      child: _TitleBody(title: word, body: meaning),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({
    required this.color,
    required this.items,
  });

  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    return _BaseCard(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    color: AppColors.royalPurple,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: mutedColor,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  const _BaseCard({
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black12,
        ),
      ),
      child: child,
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.royalPurple.withOpacity(0.14),
      child: Icon(
        icon,
        color: AppColors.royalPurple,
        size: 22,
      ),
    );
  }
}

class _TitleBody extends StatelessWidget {
  const _TitleBody({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final mutedColor = isDark ? Colors.white70 : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          body,
          style: TextStyle(
            color: mutedColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
