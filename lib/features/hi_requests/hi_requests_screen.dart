import 'package:flutter/material.dart';

class HiRequestsScreen extends StatelessWidget {
  const HiRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = ['Ava sent Hi 👋', 'Emma wants to connect', 'Noah is nearby'];

    return Scaffold(
      appBar: AppBar(title: const Text('Hi Requests')),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: requests.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
            title: Text(requests[index]),
            subtitle: const Text('Connection requires mutual consent.'),
            trailing: Wrap(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.close_rounded)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.check_circle_rounded)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
