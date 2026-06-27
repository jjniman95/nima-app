import 'package:flutter/material.dart';
import '../../core/constants/app_text.dart';
import '../auth/otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _goOtp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OtpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Phone Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome to NIMA', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(AppText.tagline),
            const SizedBox(height: 32),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '+94 7X XXX XXXX',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _goOtp(context),
              child: const Text('Send OTP'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Firebase Phone Authentication will be connected in the next development step.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
