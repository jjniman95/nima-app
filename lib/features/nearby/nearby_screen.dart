import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../hi_requests/hi_requests_screen.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = MockDataService.nearbyUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.waving_hand_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HiRequestsScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.royalPurple.withOpacity(0.25),
                    AppColors.royalPurple.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(radius: 28, child: Text('Me')),
                  Positioned(top: 55, left: 85, child: _Dot(name: users[0].nickname)),
                  Positioned(bottom: 65, right: 70, child: _Dot(name: users[1].nickname)),
                  Positioned(top: 100, right: 40, child: _Dot(name: users[2].nickname)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('People nearby', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, i) {
                  final user = users[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(user.nickname[0])),
                      title: Text('${user.nickname}, ${user.age}'),
                      subtitle: Text(user.interests.join(' • ')),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Say Hi'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          backgroundColor: AppColors.royalPurple,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(name),
      ],
    );
  }
}
