import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../../core/widgets/nima_gradient_logo.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 @override
void initState() {
  super.initState();
  _checkProfile();
}

Future<void> _checkProfile() async {
  await Future.delayed(const Duration(seconds: 2));

  final prefs = await SharedPreferences.getInstance();
  final completed = prefs.getBool('profileCompleted') ?? false;

  if (!mounted) return;

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) =>
          completed ? const HomeScreen() : const OnboardingScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NimaGradientLogo(size: 170),
                SizedBox(height: 32),
                Text(
                  AppText.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  AppText.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
