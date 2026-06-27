import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../../core/router/app_router.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

/// [LoginScreen] — Phone number entry.
///
/// Responsibilities:
///   1. Show a phone number input with country code picker.
///   2. On "Send OTP", call [AuthNotifier.sendOtp].
///   3. Listen to [AuthState] and navigate to OTP screen on [AuthCodeSent].
///   4. Show inline error on [AuthError].
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// Full E.164 phone number e.g. "+94712345678"
  String _phoneNumber = '';

  /// Tracks whether the phone field has a valid number
  bool _isPhoneValid = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Listen to auth state AFTER the first frame to safely navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToAuthState();
    });
  }

  void _listenToAuthState() {
    // ref.listen is the correct way to react to state changes that
    // trigger side-effects (navigation, snackbars) — NOT ref.watch.
    ref.listenManual(
      authNotifierProvider,
      (previous, next) {
        switch (next) {
          // ── Navigate to OTP screen ────────────────────────────────────────
          case AuthCodeSent(:final phoneNumber):
            context.push(AppRoutes.otp, extra: phoneNumber);

          // ── Auto-verified on Android (no OTP screen needed) ───────────────
          case AuthAuthenticated(:final isNewUser):
            if (isNewUser) {
              context.go(AppRoutes.createProfile);
            } else {
              context.go(AppRoutes.home);
            }

          // ── Show error ────────────────────────────────────────────────────
          case AuthError(:final message):
            _showError(message);

          default:
            break;
        }
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _onSendOtp() async {
    if (!_isPhoneValid) {
      _showError(AppText.invalidPhone);
      return;
    }

    // Dismiss keyboard before transitioning
    FocusScope.of(context).unfocus();

    await ref.read(authNotifierProvider.notifier).sendOtp(_phoneNumber);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Watch for loading state to disable the button and show a spinner
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthSendingOtp;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo / Brand ───────────────────────────────────────────────
              _NimaLogo(),
              const SizedBox(height: 48),

              // ── Headline ───────────────────────────────────────────────────
              Text(
                AppText.welcomeBack,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppText.enterPhone,
                style: textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // ── Phone Field ────────────────────────────────────────────────
              IntlPhoneField(
                // Styled to match NIMA's InputDecorationTheme
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: AppColors.royalPurple,
                      width: 2,
                    ),
                  ),
                ),
                initialCountryCode: 'LK', // Default to Sri Lanka 🇱🇰
                keyboardType: TextInputType.phone,
                onChanged: (phone) {
                  setState(() {
                    _phoneNumber = phone.completeNumber; // e.g. "+94712345678"
                    _isPhoneValid = phone.isValidNumber();
                  });
                },
                onSubmitted: (_) => _onSendOtp(),
                enabled: !isLoading,
              ),
              const SizedBox(height: 32),

              // ── Send OTP Button ────────────────────────────────────────────
              ElevatedButton(
                onPressed: isLoading ? null : _onSendOtp,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(AppText.sendOtp),
              ),
              const SizedBox(height: 24),

              // ── Legal fine print ───────────────────────────────────────────
              Center(
                child: Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

/// NIMA wordmark / logo lockup.
/// Swap this for an Image.asset() once you have a logo file.
class _NimaLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.royalPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppText.appName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.royalPurple,
              ),
            ),
            Text(
              AppText.tagline,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.royalPurple.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
