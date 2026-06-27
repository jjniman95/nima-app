/// NIMA Design System — String Constants
///
/// All user-facing strings live here for easy localisation later.
abstract final class AppText {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const String appName = 'NIMA';
  static const String meaning = 'Nearby Instant Meet App';
  static const String tagline = 'Meet safely, connect silently.';
  static const String slogan = 'Connecting people with consent.';
  }

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String loginTitle = 'Welcome to NIMA';
  static const String loginSubtitle = 'Enter your phone number to continue.';
  static const String phoneHint = '+94 7X XXX XXXX';
  static const String sendOtp = 'Send OTP';
  static const String verifyOtp = 'Verify Code';
  static const String enterOtp = 'Enter the 6-digit code sent to';
  static const String resendOtp = 'Resend code';
  static const String otpSent = 'OTP sent successfully!';
  static const String verifyOtp = 'Verify';
  static const String privacyFirst = 'Privacy First';
  static const String privacyFirstDesc = 'You decide when you are visible.';
  static const String consentAlways = 'Consent Always';
  static const String consentAlwaysDesc =
      'Chats begin only after mutual acceptance.';

  static const String connectNearby = 'Connect Nearby';
  static const String connectNearbyDesc =
      'Discover people around you respectfully.';
}

  // ── Errors ───────────────────────────────────────────────────────────────
  static const String invalidPhone = 'Please enter a valid phone number.';
  static const String invalidOtp = 'The code you entered is incorrect.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Check your internet connection.';
  static const String otpExpired = 'This code has expired. Please resend.';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String createProfile = 'Create your profile';
  static const String profileSubtitle = 'This is how others will see you nearby.';

  // ── Radar ─────────────────────────────────────────────────────────────────
  static const String nearbyPeople = 'People Nearby';
  static const String noOneNearby = 'No one nearby right now.';
  static const String radarScanning = 'Scanning nearby...';

  // ── Hi Request ────────────────────────────────────────────────────────────
  static const String sendHi = 'Say Hi 👋';
  static const String hiSent = 'Hi request sent!';
  static const String hiReceived = 'wants to connect with you';
  static const String accept = 'Accept';
  static const String decline = 'Decline';

  // ── Chat ──────────────────────────────────────────────────────────────────
  static const String typeMessage = 'Type a message...';
  static const String chatLimitReached = 'Chat limit reached';
  static const String chatLimitBody =
      'Free chats are limited to 10 minutes or 20 messages. Upgrade to keep talking.';
  static const String upgradeToPremium = 'Upgrade to Premium';
}
