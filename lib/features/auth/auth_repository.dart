import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// [AuthRepository] is responsible for ALL Firebase Auth interactions.
///
/// Design principles:
///  - No UI code, no BuildContext, no Navigator here.
///  - All methods throw typed [AuthException] so callers can handle errors
///    without parsing raw Firebase error strings.
///  - Injected [FirebaseAuth] instance makes this unit-testable.
class AuthRepository {
  const AuthRepository(this._auth);

  final FirebaseAuth _auth;

  // ── Stream ────────────────────────────────────────────────────────────────

  /// Emits the current [User] whenever auth state changes (login / logout).
  /// Emits null when the user is signed out.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// The currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  // ── Phone Auth ────────────────────────────────────────────────────────────

  /// Triggers Firebase to send an OTP SMS to [phoneNumber].
  ///
  /// Calls [onCodeSent] with the [verificationId] and optional [resendToken]
  /// when Firebase has dispatched the SMS.
  ///
  /// Calls [onError] if anything goes wrong (invalid number, quota exceeded…).
  ///
  /// [onAutoVerified] is called on Android if Firebase detects the SMS
  /// automatically (instant sign-in without user typing the code).
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String message) onError,
    void Function(User user, bool isNewUser)? onAutoVerified,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),

      // ── Happy path: SMS delivered ────────────────────────────────────────
      codeSent: (verificationId, newResendToken) {
        onCodeSent(verificationId, newResendToken);
      },

      // ── Android auto-verification ─────────────────────────────────────────
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final result = await _auth.signInWithCredential(credential);
          final user = result.user;
          if (user != null && onAutoVerified != null) {
            final isNew = result.additionalUserInfo?.isNewUser ?? false;
            onAutoVerified(user, isNew);
          }
        } on FirebaseAuthException catch (e) {
          onError(_mapFirebaseError(e.code));
        }
      },

      // ── Verification failed (wrong number, quota, etc.) ───────────────────
      verificationFailed: (FirebaseAuthException e) {
        onError(_mapFirebaseError(e.code));
      },

      // ── Timeout (rare, normally only on iOS simulator) ────────────────────
      codeAutoRetrievalTimeout: (_) {
        // No action needed — user can still manually verify.
      },
    );
  }

  /// Verifies the 6-digit [smsCode] against the [verificationId] received
  /// during [sendOtp]. Returns [({User user, bool isNewUser})].
  ///
  /// Throws [AuthException] on failure.
  Future<({User user, bool isNewUser})> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) throw const AuthException('sign_in_failed');
      final isNew = result.additionalUserInfo?.isNewUser ?? false;
      return (user: user, isNewUser: isNew);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Error Mapping ─────────────────────────────────────────────────────────

  /// Maps raw Firebase error codes to human-readable NIMA messages.
  static String _mapFirebaseError(String code) {
    return switch (code) {
      'invalid-phone-number'  => 'Please enter a valid phone number with country code.',
      'too-many-requests'     => 'Too many attempts. Please wait a moment and try again.',
      'invalid-verification-code' => 'That code is incorrect. Please check and try again.',
      'session-expired'       => 'This code has expired. Please request a new one.',
      'quota-exceeded'        => 'SMS quota exceeded. Please try again later.',
      'network-request-failed' => 'No internet connection. Please check your network.',
      'user-disabled'         => 'This account has been disabled.',
      _                       => 'Something went wrong. Please try again.',
    };
  }
}

/// Typed exception for auth errors — avoids stringly-typed error handling.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

// ── Riverpod Providers ────────────────────────────────────────────────────────

/// Provides the [FirebaseAuth] singleton.
@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

/// Provides the [AuthRepository] singleton, injecting [FirebaseAuth].
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
}

/// Stream provider for auth state changes.
/// The router listens to this to decide where to send the user.
@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}
