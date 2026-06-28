import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
