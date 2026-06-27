import 'package:flutter/material.dart';

class HiRequestsScreen extends StatelessWidget {
  const HiRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = ['Emma, 23', 'Ava, 24', 'Noah, 25'];

    return Scaffold(
      appBar: AppBar(title: const Text('Hi Requests')),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(requests[index]),
              subtitle: const Text('Wants to say Hi 👋'),
              trailing: Wrap(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.check_circle)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
