import '../../features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/auth_repository.dart';
import '../../features/auth/auth_notifier.dart';
import '../../features/auth/auth_state.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_screen.dart';
// TODO Phase 2+: import remaining screens
// import '../features/profile/create_profile_screen.dart';
// import '../features/home/home_screen.dart';

part 'app_router.g.dart';

// ── Route Name Constants ──────────────────────────────────────────────────────
// Using constants prevents typos and makes refactoring safe.
abstract final class AppRoutes {
  static const String splash        = '/';
  static const String login         = '/login';
  static const String otp           = '/otp';
  static const String createProfile = '/create-profile';
  static const String home          = '/home';
  static const String radar         = '/home/radar';
  static const String hiRequests    = '/home/hi-requests';
  static const String chats         = '/home/chats';
  static const String settings      = '/settings';
  static const String premium       = '/premium';
}

/// The [GoRouter] instance, provided via Riverpod so it can react to
/// auth state changes automatically using [refreshListenable].
@riverpod
GoRouter appRouter(Ref ref) {
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true, // Set to false for production builds

    // ── Auth Redirect Logic ─────────────────────────────────────────────────
    //
    // This function is called on EVERY navigation event.
    // It acts as a guard: redirect if the user shouldn't be on this route.
    redirect: (BuildContext context, GoRouterState routerState) {
      final location = routerState.matchedLocation;
      final isAuthenticated = authState.valueOrNull != null;

      // Routes that don't require authentication
      final publicRoutes = {
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.otp,
      };

      final isOnPublicRoute = publicRoutes.contains(location);

      // ── Not authenticated, trying to access private route ─────────────────
      if (!isAuthenticated && !isOnPublicRoute) {
        return AppRoutes.login;
      }

      // ── Authenticated, lingering on public route ───────────────────────────
      // (e.g. user presses back to login while already logged in)
      if (isAuthenticated && isOnPublicRoute && location != AppRoutes.splash) {
        // TODO Phase 2: Check if profile is complete, redirect to createProfile if not
        return AppRoutes.home;
      }

      return null; // No redirect needed
    },

    routes: [
      // ── Splash ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth ───────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        // Pass phoneNumber as extra so OTP screen can display it
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phoneNumber);
        },
      ),

      // ── TODO: Add remaining routes in Phase 2+ ────────────────────────────
      // GoRoute(
      //   path: AppRoutes.createProfile,
      //   builder: (context, state) => const CreateProfileScreen(),
      // ),
      // GoRoute(
      //   path: AppRoutes.home,
      //   builder: (context, state) => const HomeScreen(),
      // ),
    ],

    // ── Error Page ─────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.matchedLocation}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ),
  );
}
