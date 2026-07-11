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
  final seenPairs = <String>{};
  final requests = <HiRequest>[];

  for (final doc in snapshot.docs) {
    final data = doc.data();

    if (data['senderId'] != pulseId &&
        data['receiverId'] != pulseId) {
      continue;
    }

    final sender = data['senderId'] as String;
    final receiver = data['receiverId'] as String;

    final ids = [sender, receiver]..sort();
    final pairKey = '${ids[0]}_${ids[1]}';

    // Already showing this pair?
    if (seenPairs.contains(pairKey)) {
      continue;
    }

    seenPairs.add(pairKey);

    requests.add(
      HiRequest.fromMap(doc.id, data),
    );
  }

  return requests;
});
  }

@override
Future<void> sendHi({
  required String senderId,
  required String senderNickname,
  required String receiverId,
  required String receiverNickname,
}) async {
  final now = DateTime.now();
  final pairIds = [senderId, receiverId]..sort();
  final pairKey = '${pairIds[0]}_${pairIds[1]}';

  final requestsRef = _db.collection('hi_requests');

  // Find old requests in both directions, including older documents
  // created before pairKey was introduced.
  final results = await Future.wait([
    requestsRef
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get(),
    requestsRef
        .where('senderId', isEqualTo: receiverId)
        .where('receiverId', isEqualTo: senderId)
        .get(),
  ]);

  // A fixed document ID guarantees one stored request per Pulse pair.
  final newRequestRef = requestsRef.doc(pairKey);
  final batch = _db.batch();

  final oldReferences = {
    for (final result in results)
      for (final document in result.docs) document.reference,
  };

  for (final reference in oldReferences) {
    if (reference.path != newRequestRef.path) {
      batch.delete(reference);
    }
  }

  batch.set(newRequestRef, {
    'pairKey': pairKey,
    'senderId': senderId,
    'senderNickname': senderNickname,
    'receiverId': receiverId,
    'receiverNickname': receiverNickname,
    'status': 'pending',
    'createdAt': Timestamp.fromDate(now),
    'popupExpiresAt': Timestamp.fromDate(
      now.add(const Duration(minutes: 1)),
    ),
    'missedAt': Timestamp.fromDate(
      now.add(const Duration(minutes: 2)),
    ),
    'expiresAt': Timestamp.fromDate(
      now.add(const Duration(minutes: 10)),
    ),
    'nearbyOnly': true,
    'requiresReacceptAfterMinutes': 10,
    'conversationId': null,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  await batch.commit();
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
Future<void> updateRequestMessageStatus({
  required String conversationId,
  required String messageId,
  required String status,
}) async {
  await _db
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .doc(messageId)
      .update({
    'payload.status': status,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
  
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    await sendTextMessage(
      conversationId: conversationId,
      senderId: senderId,
      text: text,
    );
  }

  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    
    await _sendTypedMessage(
      conversationId: conversationId,
      senderId: senderId,
      type: PulseMessageType.text,
      text: trimmed,
      lastMessage: trimmed,
    );
  }

  Future<void> sendAboutPulseRequest({
    required String conversationId,
    required String senderId,
    required String senderNickname,
  }) async {
    await _sendTypedMessage(
      conversationId: conversationId,
      senderId: senderId,
      type: PulseMessageType.aboutPulseRequest,
      text: '$senderNickname wants to know more about you.',
      payload: {
        'requesterId': senderId,
        'requesterNickname': senderNickname,
        'status': 'pending',
      },
      lastMessage: '$senderNickname requested About Pulse',
    );
  }

  Future<void> sendAboutPulseShared({
    required String conversationId,
    required String senderId,
    required String senderNickname,
    required Map<String, dynamic> sharedDetails,
  }) async {
    if (sharedDetails.isEmpty) return;

    await _sendTypedMessage(
      conversationId: conversationId,
      senderId: senderId,
      type: PulseMessageType.aboutPulseShared,
      text: '$senderNickname shared About Pulse details.',
      payload: {
        'sharerId': senderId,
        'sharerNickname': senderNickname,
        'details': sharedDetails,
      },
      lastMessage: '$senderNickname shared About Pulse',
    );
  }

  Future<void> sendSocialRequest({
    required String conversationId,
    required String senderId,
    required String senderNickname,
  }) async {
    await _sendTypedMessage(
      conversationId: conversationId,
      senderId: senderId,
      type: PulseMessageType.socialRequest,
      text: '$senderNickname wants to connect beyond NIMA.',
      payload: {
        'requesterId': senderId,
        'requesterNickname': senderNickname,
        'status': 'pending',
      },
      lastMessage: '$senderNickname requested Connect Beyond NIMA',
    );
  }

  Future<void> sendSocialShared({
    required String conversationId,
    required String senderId,
    required String senderNickname,
    required Map<String, dynamic> sharedSocials,
  }) async {
    if (sharedSocials.isEmpty) return;

    await _sendTypedMessage(
      conversationId: conversationId,
      senderId: senderId,
      type: PulseMessageType.socialShared,
      text: '$senderNickname shared contact details.',
      payload: {
        'sharerId': senderId,
        'sharerNickname': senderNickname,
        'socials': sharedSocials,
      },
      lastMessage: '$senderNickname shared contact details',
    );
  }

  Future<void> sendSystemMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _sendTypedMessage(
      conversationId: conversationId,
      senderId: senderId,
      type: PulseMessageType.system,
      text: trimmed,
      lastMessage: trimmed,
    );
  }

  Future<void> _sendTypedMessage({
    required String conversationId,
    required String senderId,
    required PulseMessageType type,
    required String text,
    Map<String, dynamic> payload = const {},
    required String lastMessage,
  }) async {
    final conversationRef = _db.collection('conversations').doc(conversationId);
    final expiresAt = Timestamp.fromDate(DateTime.now().add(mergeDuration));

    await conversationRef.collection('messages').add({
      'senderId': senderId,
      'type': type.name,
      'text': text,
      'payload': payload,
      'sentAt': FieldValue.serverTimestamp(),
      'sentAtLabel': 'Now',
      'seen': false,
      'seenAt': null,
    });

    await conversationRef.set({
      'lastMessage': lastMessage,
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
