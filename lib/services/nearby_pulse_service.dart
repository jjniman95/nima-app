import '../models/hi_request.dart';
import '../models/pulse_message.dart';
import 'pulse_service.dart';

/// ------------------------------------------------------------
/// Nearby Pulse Service
///
/// Future offline implementation.
///
/// This will eventually use Bluetooth / Wi-Fi Direct / Nearby
/// Connections for internet-free nearby communication.
/// ------------------------------------------------------------
class NearbyPulseService implements PulseService {
  NearbyPulseService._();

  static final NearbyPulseService instance = NearbyPulseService._();

  @override
  Stream<List<HiRequest>> streamHiRequests(String pulseId) {
    throw UnimplementedError('NearbyPulseService is not implemented yet.');
  }

  @override
  Future<void> sendHi({
    required String senderId,
    required String senderNickname,
    required String receiverId,
    required String receiverNickname,
  }) {
    throw UnimplementedError('NearbyPulseService is not implemented yet.');
  }

  @override
  Future<String> acceptHi({required HiRequest request}) {
    throw UnimplementedError('NearbyPulseService is not implemented yet.');
  }

  @override
  Future<void> declineHi({required String requestId}) {
    throw UnimplementedError('NearbyPulseService is not implemented yet.');
  }

  @override
  Stream<List<PulseMessage>> streamMessages({required String conversationId}) {
    throw UnimplementedError('NearbyPulseService is not implemented yet.');
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) {
    throw UnimplementedError('NearbyPulseService is not implemented yet.');
  }

  @override
  Future<void> markSeen({
    required String conversationId,
    required String currentPulseId,
  }) {
    throw UnimplementedError('NearbyPulseService is not implemented yet.');
  }

  @override
  Future<void> updateTyping({
    required String conversationId,
    required String pulseId,
    required bool typing,
  }) {
    throw UnimplementedError('NearbyPulseService is not implemented yet.');
  }

  @override
  Future<void> expireMerge({required String conversationId}) {
    throw UnimplementedError('NearbyPulseService is not implemented yet.');
  }
}
