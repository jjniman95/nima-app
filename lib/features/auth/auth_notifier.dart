import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

/// [AuthNotifier] owns and drives the [AuthState] machine.
///
/// It is the ONLY place where [AuthState] transitions happen.
/// UI screens call methods on this notifier and observe state changes.
///
/// It deliberately has no reference to BuildContext or any UI widget.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  // ── Initial State ─────────────────────────────────────────────────────────

  @override
  AuthState build() => const AuthInitial();

  // ── Convenience Getters ───────────────────────────────────────────────────

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  // ── Public API ────────────────────────────────────────────────────────────

  /// Called when the user taps "Send OTP" on [LoginScreen].
  ///
  /// Transitions:
  ///   AuthInitial / AuthError  →  AuthSendingOtp
  ///   AuthSendingOtp           →  AuthCodeSent   (on success)
  ///   AuthSendingOtp           →  AuthError      (on failure)
  Future<void> sendOtp(String phoneNumber) async {
    // Don't re-send if already in-flight
    if (state is AuthSendingOtp) return;

    state = const AuthSendingOtp();

    // Pull existing resend token if we're resending
    final resendToken = switch (state) {
      AuthCodeSent(:final resendToken) => resendToken,
      _ => null,
    };

    await _repo.sendOtp(
      phoneNumber: phoneNumber,
      resendToken: resendToken,

      onCodeSent: (verificationId, newResendToken) {
        state = AuthCodeSent(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
          resendToken: newResendToken,
        );
      },

      onError: (message) {
        state = AuthError(message: message);
      },

      // Android auto-detection: SMS read without user input
      onAutoVerified: (user, isNewUser) {
        state = AuthAuthenticated(user: user, isNewUser: isNewUser);
      },
    );
  }

  /// Called when the user taps "Verify" on [OtpScreen].
  ///
  /// Transitions:
  ///   AuthCodeSent     →  AuthVerifyingOtp
  ///   AuthVerifyingOtp →  AuthAuthenticated  (on success)
  ///   AuthVerifyingOtp →  AuthError          (on failure)
  Future<void> verifyOtp(String smsCode) async {
    // Safety check — we must have a verificationId to proceed
    final currentState = state;
    if (currentState is! AuthCodeSent) {
      state = const AuthError(
        message: 'Session expired. Please request a new OTP.',
      );
      return;
    }

    state = const AuthVerifyingOtp();

    try {
      final (:user, :isNewUser) = await _repo.verifyOtp(
        verificationId: currentState.verificationId,
        smsCode: smsCode,
      );
      state = AuthAuthenticated(user: user, isNewUser: isNewUser);
    } on AuthException catch (e) {
      state = AuthError(message: e.message);
    }
  }

  /// Called when the user taps "Resend OTP".
  /// Reuses the [resendToken] from [AuthCodeSent] to avoid reCAPTCHA on Android.
  Future<void> resendOtp() async {
    final currentState = state;
    if (currentState is! AuthCodeSent) return;

    // Use the same phone number, pass the resend token
    state = const AuthSendingOtp();

    await _repo.sendOtp(
      phoneNumber: currentState.phoneNumber,
      resendToken: currentState.resendToken,

      onCodeSent: (verificationId, newResendToken) {
        state = AuthCodeSent(
          verificationId: verificationId,
          phoneNumber: currentState.phoneNumber,
          resendToken: newResendToken,
        );
      },

      onError: (message) {
        state = AuthError(message: message);
      },
    );
  }

  /// Resets state back to [AuthInitial].
  /// Called when the user taps "back" on the OTP screen.
  void resetToInitial() {
    state = const AuthInitial();
  }

  /// Signs out and resets state.
  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthInitial();
  }
}
