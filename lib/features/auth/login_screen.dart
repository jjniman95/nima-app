import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../profile/create_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController(text: '+94 ');

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _continueDemo() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
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
              Text('Welcome to NIMA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textDark,
                  )),
              const SizedBox(height: 10),
              Text(
                'Enter your phone number to continue. Firebase OTP will be connected in the next phase.',
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
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _continueDemo,
                child: const Text('Continue Demo'),
              ),
              const SizedBox(height: 14),
              Text(
                'This clean build does not include Firebase yet. First we confirm the app is stable.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
