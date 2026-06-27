import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../../core/router/app_router.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

/// [OtpScreen] — 6-digit code verification.
///
/// Receives [phoneNumber] from the router (passed as `extra` from LoginScreen).
///
/// Features:
///   - 6 individual digit boxes (better UX than a single field)
///   - Auto-advances focus between boxes
///   - Backspace clears and moves back
///   - Resend OTP with 60s countdown timer
///   - Loading state while verifying
///   - Navigates to CreateProfile (new user) or Home (existing user)
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // 6 controllers + 6 focus nodes for the individual digit boxes
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  // Resend countdown
  static const _resendCooldownSeconds = 60;
  int _secondsRemaining = _resendCooldownSeconds;
  Timer? _resendTimer;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToAuthState();
      // Focus the first box automatically
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes)  { f.dispose(); }
    _resendTimer?.cancel();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void _startResendTimer() {
    _secondsRemaining = _resendCooldownSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // ── Auth State Listener ───────────────────────────────────────────────────

  void _listenToAuthState() {
    ref.listenManual(
      authNotifierProvider,
      (previous, next) {
        switch (next) {
          case AuthAuthenticated(:final isNewUser):
            if (isNewUser) {
              context.go(AppRoutes.createProfile);
            } else {
              context.go(AppRoutes.home);
            }

          // Resent OTP successfully
          case AuthCodeSent():
            _startResendTimer();
            _showInfo(AppText.otpSent);
            _clearBoxes();

          case AuthError(:final message):
            _showError(message);
            _clearBoxes();

          default:
            break;
        }
      },
    );
  }

  // ── OTP Box Logic ─────────────────────────────────────────────────────────

  String get _currentCode =>
      _controllers.map((c) => c.text).join();

  void _onDigitEntered(int index, String value) {
    if (value.isEmpty) return;

    // Only keep the last character in case of paste
    final digit = value.characters.last;
    _controllers[index].text = digit;
    _controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: 1),
    );

    if (index < 5) {
      // Advance to next box
      _focusNodes[index + 1].requestFocus();
    } else {
      // Last box filled — auto-submit
      _focusNodes[index].unfocus();
      _onVerify();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].clear();
    } else if (index > 0) {
      // Move back and clear previous box
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  void _clearBoxes() {
    for (final c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _onVerify() async {
    final code = _currentCode;
    if (code.length < 6) {
      _showError('Please enter the full 6-digit code.');
      return;
    }
    FocusScope.of(context).unfocus();
    await ref.read(authNotifierProvider.notifier).verifyOtp(code);
  }

  Future<void> _onResend() async {
    if (_secondsRemaining > 0) return;
    await ref.read(authNotifierProvider.notifier).resendOtp();
  }

  void _onBack() {
    ref.read(authNotifierProvider.notifier).resetToInitial();
    context.pop();
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

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
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
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthVerifyingOtp || authState is AuthSendingOtp;

    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: isLoading ? null : _onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Headline ───────────────────────────────────────────────────
              Text(
                'Verify Code',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  children: [
                    const TextSpan(text: '${AppText.enterOtp} '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        color: AppColors.royalPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── 6 Digit Boxes ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    enabled: !isLoading,
                    onChanged: (v) => _onDigitEntered(i, v),
                    onBackspace: () => _onBackspace(i),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Verify Button ──────────────────────────────────────────────
              ElevatedButton(
                onPressed: isLoading ? null : _onVerify,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(AppText.verifyOtp),
              ),
              const SizedBox(height: 24),

              // ── Resend OTP ─────────────────────────────────────────────────
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Resend code in $_secondsRemaining s',
                        style: textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      )
                    : TextButton(
                        onPressed: isLoading ? null : _onResend,
                        child: const Text(
                          AppText.resendOtp,
                          style: TextStyle(
                            color: AppColors.royalPurple,
                            fontWeight: FontWeight.w600,
                          ),
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

/// A single digit input box in the OTP grid.
///
/// Uses a [RawKeyboardListener] to catch backspace since [TextField.onChanged]
/// doesn't fire on empty backspace presses.
class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFocus = focusNode.hasFocus;

    return SizedBox(
      width: 46,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(), // Separate node for key listener
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.royalPurple,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.darkSurface
                    : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.royalPurple,
                width: 2.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
