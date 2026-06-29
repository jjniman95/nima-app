import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController(text: '+94');

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.length < 10) {
      _showError('Enter a valid phone number.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phoneNumber: phone,
          verificationId: 'debug',
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.red,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Phone Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to NIMA',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter your phone number to continue.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: isDark ? Colors.white70 : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 34),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+947XXXXXXXX',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _sendOtp,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
