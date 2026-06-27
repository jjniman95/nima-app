# NIMA — Phase 1 Setup Guide
## Architecture & Firebase Phone Authentication

---

## 📁 File Placement Map

Place each generated file exactly as shown:

```
nima_app/
├── pubspec.yaml                          ← REPLACE with Phase 1 version
├── lib/
│   ├── main.dart                         ← REPLACE
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart           ← REPLACE (adds semantic tokens)
│   │   │   └── app_text.dart             ← REPLACE (adds auth strings)
│   │   │
│   │   └── router/
│   │       └── app_router.dart           ← NEW FILE
│   │
│   └── features/
│       └── auth/
│           ├── auth_state.dart           ← NEW FILE
│           ├── auth_repository.dart      ← NEW FILE
│           ├── auth_notifier.dart        ← NEW FILE
│           ├── login_screen.dart         ← REPLACE
│           └── otp_screen.dart           ← REPLACE
│
└── (your existing files: splash, profile, home screens are UNCHANGED)
```

---

## 🔧 Step 1 — Firebase Project Setup

### 1a. Install FlutterFire CLI (one-time)
```bash
dart pub global activate flutterfire_cli
```

### 1b. Connect your Flutter app to Firebase
```bash
# In your project root:
flutterfire configure
```
- Select your Firebase project (or create one)
- Select platforms: Android ✅  iOS ✅
- This generates: `lib/firebase_options.dart` ← required by main.dart

---

## 🔧 Step 2 — Enable Phone Auth in Firebase Console

1. Go to: Firebase Console → Authentication → Sign-in method
2. Enable **Phone** provider
3. (Optional for testing) Add a test phone number:
   - Phone: `+94 712 345 678`
   - Code: `123456`
   - This avoids SMS costs during development

---

## 🔧 Step 3 — Android Setup

### 3a. Add SHA-1 fingerprint (required for Phone Auth)
```bash
cd android
./gradlew signingReport
```
Copy the **SHA-1** value.

Firebase Console → Project Settings → Your Android app → Add fingerprint → paste SHA-1

### 3b. Download & replace google-services.json
After adding SHA-1, download `google-services.json` from Firebase Console
and replace: `android/app/google-services.json`

### 3c. Enable reCAPTCHA bypass for debug (optional)
In `android/app/build.gradle`, verify:
```gradle
defaultConfig {
    // ...
    minSdkVersion 21   // minimum required for Firebase
}
```

---

## 🔧 Step 4 — iOS Setup

### 4a. Add URL Scheme for reCAPTCHA
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target → Info → URL Types → Add:
   - URL Scheme: your `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`
   - Example: `com.googleusercontent.apps.YOUR_CLIENT_ID`

### 4b. Enable Push Notifications capability
- Xcode → Runner target → Signing & Capabilities → + Capability → Push Notifications

---

## 🔧 Step 5 — Install Dependencies & Generate Code

```bash
# Install all packages
flutter pub get

# Generate Riverpod providers from @riverpod annotations
dart run build_runner build --delete-conflicting-outputs
```

This creates:
- `lib/features/auth/auth_repository.g.dart`
- `lib/features/auth/auth_notifier.g.dart`
- `lib/core/router/app_router.g.dart`

### Watch mode (during development)
```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## 🔧 Step 6 — Temp Placeholder Screens

Until Phase 2 screens are built, create empty placeholder files:

### lib/features/profile/create_profile_screen.dart
```dart
import 'package:flutter/material.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Create Profile — Phase 2')),
    );
  }
}
```

### lib/features/home/home_screen.dart
```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home — Phase 2')),
    );
  }
}
```

---

## 🔧 Step 7 — Uncomment Router Imports

After creating the placeholder screens, open `app_router.dart` and
uncomment these lines:

```dart
import '../features/profile/create_profile_screen.dart';
import '../features/home/home_screen.dart';
```

And uncomment the corresponding GoRoute entries.

---

## ✅ Verification Checklist

Run the app and confirm:

- [ ] App launches to SplashScreen
- [ ] SplashScreen navigates to LoginScreen
- [ ] Phone field shows Sri Lanka (+94) as default country
- [ ] Tapping "Send OTP" shows loading spinner
- [ ] Firebase sends SMS (or test code works in console)
- [ ] App navigates to OtpScreen showing the phone number
- [ ] Typing 6 digits auto-submits
- [ ] Backspace navigates between boxes correctly
- [ ] Resend button shows 60s countdown
- [ ] Correct OTP → navigates to CreateProfile (new) or Home (returning)
- [ ] Wrong OTP → shows error snackbar in red
- [ ] Back button on OTP screen returns to Login cleanly

---

## 🏗️ Architecture Summary

```
UI Layer (Screens)
    │  ref.watch() to observe state
    │  ref.read().notifier to call actions
    ▼
State Layer (AuthNotifier)        ← AuthState machine
    │  calls repository methods
    ▼
Repository Layer (AuthRepository) ← Pure Firebase calls
    │
    ▼
Firebase Auth SDK
```

**State Flow:**
```
AuthInitial
  → [sendOtp()]  → AuthSendingOtp
                       → AuthCodeSent      (SMS delivered)
                       → AuthError         (something failed)

AuthCodeSent
  → [verifyOtp()] → AuthVerifyingOtp
                        → AuthAuthenticated  (correct code)
                        → AuthError          (wrong code)
```

---

## 🚀 Phase 2 Preview

Next we'll build:
1. `UserProfile` model with Firestore
2. `GeolocatorService` — get real device location
3. Firestore geo-query — find users within X km radius
4. Replace mock radar data with live Firestore stream

Ready when you are!
