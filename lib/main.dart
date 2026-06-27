import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NimaApp());
}

class NimaApp extends StatelessWidget {
  const NimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'NIMA',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
  themeAnimationDuration: Duration.zero,
  home: const SplashScreen(),
    );
  }
}
