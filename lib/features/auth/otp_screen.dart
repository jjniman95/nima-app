import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../profile/create_profile_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  final String phoneNumber;
  final String verificationId;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final code = otpController.text.trim();

    if (code.length != 6) {
      _showError('Enter any 6-digit code.');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Development Verification',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                'OTP SMS is skipped for now.\nEnter any 6-digit code for ${widget.phoneNumber}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '123456',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyOtp,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
