import '../models/hi_request.dart';
import '../models/pulse_message.dart';

/// ------------------------------------------------------------
/// NIMA Pulse Service
///
/// Single gateway for interactions between two Pulses.
///
/// The UI must use this service instead of talking directly to
/// Firebase, Bluetooth, Wi-Fi Direct, or any future transport.
///
/// Temporary by design.
/// Nearby-first architecture.
/// No permanent conversation history.
/// ------------------------------------------------------------
abstract class PulseService {
  Stream<List<HiRequest>> streamHiRequests(String pulseId);

  Future<void> sendHi({
    required String senderId,
    required String senderNickname,
    required String receiverId,
    required String receiverNickname,
  });

  Future<String> acceptHi({
    required HiRequest request,
  });

  Future<void> declineHi({
    required String requestId,
  });

  Stream<List<PulseMessage>> streamMessages({
    required String conversationId,
  });

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  });

  Future<void> sendAboutPulseRequest({
    required String conversationId,
    required String senderId,
    required String senderNickname,
  });

  Future<void> sendAboutPulseShared({
    required String conversationId,
    required String senderId,
    required String senderNickname,
    required Map<String, dynamic> sharedDetails,
  });

  Future<void> sendSocialRequest({
    required String conversationId,
    required String senderId,
    required String senderNickname,
  });

  Future<void> updateRequestMessageStatus({
  required String conversationId,
  required String messageId,
  required String status,
  });
  
  Future<void> sendSocialShared({
    required String conversationId,
    required String senderId,
    required String senderNickname,
    required Map<String, dynamic> sharedSocials,
  });

  Future<void> markSeen({
    required String conversationId,
    required String currentPulseId,
  });

  Future<void> updateTyping({
    required String conversationId,
    required String pulseId,
    required bool typing,
  });

  Future<void> expireMerge({
    required String conversationId,
  });
}
