import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about_pulse_screen.dart';
import '../profile/social_involment_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/nima_app_bar.dart';
import '../../models/pulse_message.dart';
import '../../services/firebase_pulse_service.dart';
import '../../services/merge_service.dart';
import '../../services/pulse_service.dart';
import 'message_input.dart';
import 'message_list.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.pulseName,
    this.conversationId,
  });

  final String pulseName;
  final String? conversationId;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final PulseService pulseService = FirebasePulseService.instance;
  final ScrollController scrollController = ScrollController();

  String? localUserId;
  String localNickname = 'NIMA User';
  Duration remaining = MergeService.mergeDuration;
  StreamSubscription<Duration>? timerSubscription;
  final List<PulseMessage> localMessages = [];

  bool get hasConversationId =>
      widget.conversationId != null && widget.conversationId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
    _startMergeTimer();
  }

  Future<void> _requestAboutPulse() async {
  if (!hasConversationId || localUserId == null) return;

  final service = pulseService as FirebasePulseService;

  await service.sendAboutPulseRequest(
    conversationId: widget.conversationId!,
    senderId: localUserId!,
    senderNickname: localNickname,
  );
  }

Future<void> _requestSocial() async {
  if (!hasConversationId || localUserId == null) return;

  final service = pulseService as FirebasePulseService;

  await service.sendSocialRequest(
    conversationId: widget.conversationId!,
    senderId: localUserId!,
    senderNickname: localNickname,
  );
}
  
  Future<void> _loadLocalUser() async {
    final prefs = await SharedPreferences.getInstance();

var id = prefs.getString('localUserId');
final nickname = prefs.getString('localNickname') ?? 'NIMA User';

    if (!mounted) return;

    setState(() => localUserId = id);

    if (hasConversationId) {
      await pulseService.markSeen(
        conversationId: widget.conversationId!,
        currentPulseId: id,
      );
      MergeService.instance.reset();
    }
  }

  void _startMergeTimer() {
    MergeService.instance.start(onExpired: _handleMergeExpired);

    timerSubscription = MergeService.instance.countdownStream.listen((value) {
      if (!mounted) return;
      setState(() => remaining = value);
    });
  }

  Future<void> _handleMergeExpired() async {
    if (hasConversationId) {
      await pulseService.expireMerge(conversationId: widget.conversationId!);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Merge Expired')),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    timerSubscription?.cancel();
    MergeService.instance.stop();
    scrollController.dispose();
    super.dispose();
  }

  String get timerText {
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _sendMessage(String text) async {
    final senderId = localUserId;
    if (senderId == null || senderId.isEmpty) return;

    if (hasConversationId) {
      await pulseService.sendMessage(
        conversationId: widget.conversationId!,
        senderId: senderId,
        text: text,
      );
    } else {
      setState(() {
        localMessages.add(
          PulseMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: senderId,
            text: text,
            sentAtLabel: 'Now',
            seen: false,
          ),
        );
      });
    }

    MergeService.instance.reset();
    Future.delayed(const Duration(milliseconds: 120), _scrollToBottom);
  }

  Future<void> _handleTyping() async {
    final senderId = localUserId;
    if (senderId == null || senderId.isEmpty) return;

    MergeService.instance.reset();

    if (hasConversationId) {
      await pulseService.updateTyping(
        conversationId: widget.conversationId!,
        pulseId: senderId,
        typing: true,
      );
    }
  }

  Future<void> _disconnectMerge() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Disconnect Merge'),
        content: const Text(
          'Are you sure you want to disconnect this merge?\n\n'
          'All messages will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (hasConversationId) {
      await pulseService.expireMerge(conversationId: widget.conversationId!);
    }

    if (!mounted) return;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _scrollToBottom() {
    if (!scrollController.hasClients) return;

    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = localUserId;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : const Color(0xFFF7F5FF);

    return Scaffold(
      backgroundColor: background,
      appBar: NimaAppBar(
        title: widget.pulseName,
        subtitle: 'Pulses Merged',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TimerPill(
                    text: timerText,
                    warning: remaining.inSeconds <= 120,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _disconnectMerge,
                    child: const Text(
                      'Disconnect',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: hasConversationId
                      ? StreamBuilder<List<PulseMessage>>(
                          stream: pulseService.streamMessages(
                            conversationId: widget.conversationId!,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text('Could not load messages.'),
                              );
                            }

                            final messages = snapshot.data ?? [];

                            if (messages.isNotEmpty) {
                              Future.delayed(
                                const Duration(milliseconds: 120),
                                _scrollToBottom,
                              );

                              pulseService.markSeen(
                                conversationId: widget.conversationId!,
                                currentPulseId: userId,
                              );
                            }

                            return MessageList(
                              controller: scrollController,
                              messages: messages,
                              currentPulseId: userId,
                            );
                          },
                        )
                      : MessageList(
                          controller: scrollController,
                          messages: localMessages,
                          currentPulseId: userId,
                        ),
                ),
                MessageInput(
  enabled: remaining.inSeconds > 0,
  onSend: _sendMessage,
  onTyping: _handleTyping,
  onAboutPulse: _requestAboutPulse,
  onSocialInvolvement: _requestSocial,
),
              ],
            ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({
    required this.text,
    required this.warning,
  });

  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? Colors.orange : AppColors.royalPurple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}
