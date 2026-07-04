import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hi_request.dart';
import '../models/pulse_message.dart';
import 'pulse_service.dart';

/// ------------------------------------------------------------
/// Firebase Pulse Service
///
/// Temporary cloud implementation of PulseService.
/// Later this can be replaced by NearbyPulseService.
/// ------------------------------------------------------------
class FirebasePulseService implements PulseService {
  FirebasePulseService._();

  static final FirebasePulseService instance = FirebasePulseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const Duration mergeDuration = Duration(minutes: 10);

  @override
  Stream<List<HiRequest>> streamHiRequests(String pulseId) {
    return _db
        .collection('hi_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['senderId'] == pulseId || data['receiverId'] == pulseId;
          })
          .map((doc) => HiRequest.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<void> sendHi({
    required String senderId,
    required String senderNickname,
    required String receiverId,
    required String receiverNickname,
  }) async {
    final now = Timestamp.now();

    await _db.collection('hi_requests').add({
      'senderId': senderId,
      'senderNickname': senderNickname,
      'receiverId': receiverId,
      'receiverNickname': receiverNickname,
      'status': 'pending',
      'createdAt': now,
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(mergeDuration),
      ),
      'nearbyOnly': true,
      'requiresReacceptAfterMinutes': 10,
    });
  }

  @override
  Future<String> acceptHi({
    required HiRequest request,
  }) async {
    final now = FieldValue.serverTimestamp();
    final mergeId = DateTime.now().millisecondsSinceEpoch.toString();
    final ids = [request.senderId, request.receiverId]..sort();

    // New Hi = new merge session.
    // Same pair is still identifiable, but every merge receives a fresh ID.
    final conversationId = '${ids[0]}_${ids[1]}_merge_$mergeId';

    final conversationRef =
        _db.collection('conversations').doc(conversationId);

    await _db.runTransaction((transaction) async {
      final requestRef = _db.collection('hi_requests').doc(request.id);

      transaction.update(requestRef, {
        'status': 'accepted',
        'acceptedAt': now,
        'conversationId': conversationId,
        'updatedAt': now,
      });

      transaction.set(conversationRef, {
        'conversationId': conversationId,
        'participants': [request.senderId, request.receiverId],
        'participantNames': {
          request.senderId: request.senderNickname,
          request.receiverId: request.receiverNickname,
        },
        'createdFromHiRequestId': request.id,
        'nearbyOnly': true,
        'mergeState': 'merging',
        'status': 'merging',
        'createdAt': now,
        'updatedAt': now,
        'mergedAt': null,
        'expiresAt': null,
        'lastActivityAt': null,
        'lastActivityBy': {
          request.senderId: null,
          request.receiverId: null,
        },
        'typingBy': {},
        'lastSeenBy': {},
        'lastMessage': '',
        'lastMessageAt': null,
        'requiresNewHi': true,
        'requiresReacceptAfterMinutes': 10,
        'deleteMessagesOnExpire': true,
      }, SetOptions(merge: true));
    });

    return conversationId;
  }

  @override
  Future<void> declineHi({
    required String requestId,
  }) async {
    await _db.collection('hi_requests').doc(requestId).update({
      'status': 'declined',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<PulseMessage>> streamMessages({
    required String conversationId,
  }) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PulseMessage.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final conversationRef = _db.collection('conversations').doc(conversationId);
    final expiresAt = Timestamp.fromDate(DateTime.now().add(mergeDuration));

    await conversationRef.collection('messages').add({
      'senderId': senderId,
      'text': trimmed,
      'sentAt': FieldValue.serverTimestamp(),
      'sentAtLabel': 'Now',
      'seen': false,
      'seenAt': null,
    });

    await conversationRef.set({
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastActivityAt': FieldValue.serverTimestamp(),
      'lastActivityBy.$senderId': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markSeen({
    required String conversationId,
    required String currentPulseId,
  }) async {
    final conversationRef = _db.collection('conversations').doc(conversationId);
    final messagesRef = conversationRef.collection('messages');

    final unread = await messagesRef
        .where('senderId', isNotEqualTo: currentPulseId)
        .where('seen', isEqualTo: false)
        .get();

    final batch = _db.batch();

    for (final doc in unread.docs) {
      batch.update(doc.reference, {
        'seen': true,
        'seenAt': FieldValue.serverTimestamp(),
      });
    }

    batch.set(
      conversationRef,
      {
        'lastSeenBy.$currentPulseId': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
        'lastActivityBy.$currentPulseId': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(mergeDuration)),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  @override
  Future<void> updateTyping({
    required String conversationId,
    required String pulseId,
    required bool typing,
  }) async {
    await _db.collection('conversations').doc(conversationId).set({
      'typingBy.$pulseId': typing,
      'lastActivityAt': FieldValue.serverTimestamp(),
      'lastActivityBy.$pulseId': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(DateTime.now().add(mergeDuration)),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> expireMerge({
    required String conversationId,
  }) async {
    final conversationRef = _db.collection('conversations').doc(conversationId);
    final messages = await conversationRef.collection('messages').get();

    final batch = _db.batch();

    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(conversationRef);
    await batch.commit();
  }
}
