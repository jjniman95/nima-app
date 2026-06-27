import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../../core/widgets/nima_feature_card.dart';
import '../../core/widgets/nima_gradient_logo.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _goLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text(AppText.appName)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            children: [
              const NimaGradientLogo(size: 110),
              const SizedBox(height: 26),
              Text(AppText.onboardingTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 38,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textDark,
                  )),
              const SizedBox(height: 14),
              Text(AppText.onboardingSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    color: isDark ? Colors.white70 : AppColors.textMuted,
                  )),
              const SizedBox(height: 34),
              const NimaFeatureCard(
                icon: Icons.privacy_tip_rounded,
                title: AppText.privacyFirst,
                subtitle: AppText.privacyFirstDesc,
              ),
              const NimaFeatureCard(
                icon: Icons.verified_user_rounded,
                title: AppText.consentAlways,
                subtitle: AppText.consentAlwaysDesc,
              ),
              const NimaFeatureCard(
                icon: Icons.radar_rounded,
                title: AppText.connectNearby,
                subtitle: AppText.connectNearbyDesc,
              ),
              const SizedBox(height: 26),
              ElevatedButton(
                onPressed: () => _goLogin(context),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _goLogin(context),
                child: const Text('I already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
