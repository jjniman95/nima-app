import '../models/chat_message.dart';
import '../models/user_profile.dart';

class MockDataService {
  static const nearbyUsers = <UserProfile>[
    UserProfile(uid: '1', nickname: 'Ava', age: 24, interests: ['Travel', 'Coffee'], visible: true, premium: false),
    UserProfile(uid: '2', nickname: 'Emma', age: 23, interests: ['Music', 'Movies'], visible: true, premium: true),
    UserProfile(uid: '3', nickname: 'Noah', age: 25, interests: ['Books', 'Fitness'], visible: true, premium: false),
  ];

  static final messages = <ChatMessage>[
    ChatMessage(messageId: 'm1', senderId: '1', message: 'Hi! Nice to meet you 👋', sentAt: DateTime.now()),
    ChatMessage(messageId: 'm2', senderId: 'me', message: 'Hello! How is your trip?', sentAt: DateTime.now()),
  ];
}
