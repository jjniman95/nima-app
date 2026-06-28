import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No users yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data();
              final nickname = data['nickname'] ?? 'NIMA User';
              final bio = data['bio'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(child: Text(nickname[0].toUpperCase())),
                  title: Text(nickname),
                  subtitle: Text(bio.toString().isEmpty ? 'Nearby user' : bio),
                  trailing: FilledButton(
                    onPressed: () {},
                    child: const Text('Say Hi'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
