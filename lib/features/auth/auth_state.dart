import 'package:firebase_auth/firebase_auth.dart';

/// Sealed class representing every possible state of the Auth flow.
///
/// Using a sealed class (Dart 3+) gives us exhaustive pattern matching —
/// the compiler will error if a state is unhandled in a switch expression.
///
/// State machine transitions:
///
///   [AuthInitial]
///       │
///       ▼  (user taps "Send OTP")
///   [AuthSendingOtp]
///       │
///       ├─ success ──▶ [AuthCodeSent]  (waiting for user to type code)
///       │
///       └─ failure ──▶ [AuthError]
///
///   [AuthCodeSent]
///       │
///       ▼  (user taps "Verify")
///   [AuthVerifyingOtp]
///       │
///       ├─ success ──▶ [AuthAuthenticated]  (new user) ──▶ CreateProfile
///       │              [AuthAuthenticated]  (existing)  ──▶ Home
///       │
///       └─ failure ──▶ [AuthError]
sealed class AuthState {
  const AuthState();
}

/// Default state. Nothing has happened yet.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Waiting for Firebase to send the OTP SMS.
final class AuthSendingOtp extends AuthState {
  const AuthSendingOtp();
}

/// OTP has been sent. We now hold the [verificationId] needed to confirm it.
/// We also store [phoneNumber] so the OTP screen can display "sent to +94..."
final class AuthCodeSent extends AuthState {
  const AuthCodeSent({
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  final String verificationId;
  final String phoneNumber;
  final int? resendToken; // Used for resend OTP without re-triggering reCAPTCHA
}

/// Waiting for Firebase to verify the code the user typed.
final class AuthVerifyingOtp extends AuthState {
  const AuthVerifyingOtp();
}

/// Firebase has verified the user. [user] is the Firebase User object.
/// [isNewUser] tells the router whether to go to CreateProfile or Home.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.user,
    required this.isNewUser,
  });

  final User user;
  final bool isNewUser;
}

/// Something went wrong at any stage.
/// [message] is a human-readable string (mapped from Firebase error codes).
final class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;
}
