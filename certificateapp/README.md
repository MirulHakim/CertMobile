import 'package:flutter/material.dart';

class RepositoryPage extends StatefulWidget {
  const RepositoryPage({super.key});

  @override
  State<RepositoryPage> createState() => _RepositoryPageState();
}

class _RepositoryPageState extends State<RepositoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Repository'),
      ),
      body: const Center(
        child: Text('Repository Page - Coming Soon'),
      ),
    );
  }
}

# CertMobile: Digital Certificate Directory

A Flutter application for secure management, issuance, and verification of digital certificates.  
Supports multiple user roles: **Admin**, **Certificate Authority (CA)**, **Client**, and **Recipient**.

---

## Features

* **Firebase Authentication** (Email/Password)
* **Google Sign-In Authentication** (Coming Soon)
* **Role-based Dashboards** (Admin, CA, Client, Recipient)
* **Certificate Issuance & Upload**
* **Certificate Verification**
* **True Copy Requests & Approval**
* **PDF Certificate Preview**
* **Shareable Certificate Links**
* **System Analytics & Logs (Admin)**

---

## Authentication Implementation

### Current Implementation

The app currently supports **Email/Password Authentication** using Firebase Auth with the following features:

#### ✅ Implemented Features:
- User registration with email and password
- User login with email and password
- Password reset functionality
- User profile management
- Automatic authentication state management
- Secure logout functionality
- User data storage in Firestore

#### 🔄 Authentication Flow:
1. **Welcome Screen** → User chooses to sign in or create account
2. **Login/Registration** → User enters credentials
3. **Firebase Authentication** → Credentials are validated
4. **User Profile Creation** → New users get a profile in Firestore
5. **Home Screen** → Authenticated users access the main app
6. **Profile Management** → Users can view and manage their profile

#### 📁 Key Files:
- `lib/services/auth_service.dart` - Main authentication service
- `lib/main.dart` - Firebase initialization and auth state management
- `lib/screens/login_page.dart` - Login UI and logic
- `lib/screens/registration_page.dart` - Registration UI and logic
- `lib/screens/profile_page.dart` - User profile and logout
- `lib/screens/welcome_page.dart` - Welcome screen

### Google Sign-In Implementation (Coming Soon)

Google Sign-In is partially configured but needs API compatibility fixes:

#### 🔧 Configuration Status:
- ✅ Firebase project configured
- ✅ Google Sign-In dependencies added
- ✅ Android configuration files present
- ❌ API compatibility issues with current google_sign_in version

#### 📁 Google Sign-In Files:
- `lib/services/google_auth_service.dart` - Google Sign-In service (placeholder)
- `android/app/google-services.json` - Firebase configuration
- `lib/firebase_options.dart` - Firebase options

---

## Getting Started

### 1. Prerequisites

* Flutter SDK (3.0.0 or higher)
* Dart SDK (comes with Flutter)
* Android Studio (for Android)
* Xcode (for iOS, macOS only)
* Firebase Project
* Node.js (for FlutterFire CLI)

---

### 2. Clone the Repository

```bash
git clone <your-repo-url>
cd certificateapp
```

---

### 3. Install Dependencies

```bash
flutter pub get
```

---

### 4. Configure Firebase

1. **Install FlutterFire CLI:**  
```bash
dart pub global activate flutterfire_cli
```

2. **Login to Firebase:**  
```bash
firebase login
```

3. **Run FlutterFire Configure:**  
```bash
flutterfire configure  
```
   * Select your Firebase project and platforms.  
   * This generates `lib/firebase_options.dart`.

4. **Enable Authentication in Firebase Console:**
   - Go to Firebase Console → Authentication → Sign-in method
   - Enable "Email/Password" authentication
   - (Optional) Enable "Google" authentication for future use

5. **Configure Firestore Database:**
   - Go to Firebase Console → Firestore Database
   - Create database in test mode
   - Set up security rules for user data

---

### 5. Run the App

* **Android/iOS:**  
```bash
flutter run
```

* **Web:**  
```bash
flutter run -d chrome
```

---

## Authentication Usage

### For Users:

1. **Registration:**
   - Open the app
   - Tap "Create Account"
   - Fill in your details (name, email, password, role, etc.)
   - Tap "Register"
   - Verify your email (if required)

2. **Login:**
   - Open the app
   - Tap "Sign In"
   - Enter your email and password
   - Tap "Login"

3. **Password Reset:**
   - On the login screen, tap "Forgot Password?"
   - Enter your email address
   - Check your email for reset instructions

4. **Logout:**
   - Go to Profile tab
   - Tap "Logout"
   - Confirm logout

### For Developers:

#### Adding Authentication to New Screens:

```dart
import '../services/auth_service.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final AuthService _authService = AuthService();
  
  // Get current user
  User? currentUser = _authService.currentUser;
  
  // Listen to auth state changes
  Stream<User?> authStateChanges = _authService.authStateChanges;
}
```

#### Checking Authentication Status:

```dart
// Check if user is logged in
if (_authService.currentUser != null) {
  // User is authenticated
  print('User ID: ${_authService.currentUser!.uid}');
  print('User Email: ${_authService.currentUser!.email}');
} else {
  // User is not authenticated
  print('No user logged in');
}
```

#### Getting User Profile:

```dart
// Get user profile from Firestore
Map<String, dynamic>? userProfile = await _authService.getUserProfile(userId);
if (userProfile != null) {
  print('User Role: ${userProfile['role']}');
  print('User Name: ${userProfile['displayName']}');
}
```

---

## Firebase Configuration

### Authentication Rules

In Firebase Console → Authentication → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Add more rules for certificates, etc.
  }
}
```

### User Profile Structure

Users are stored in Firestore with the following structure:

```json
{
  "uid": "user_id",
  "email": "user@example.com",
  "displayName": "User Name",
  "photoURL": "https://...",
  "phoneNumber": "+1234567890",
  "role": "Recipient",
  "organization": "Company Name",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp",
  "updatedAt": "timestamp",
  "isActive": true
}
```

---

## Troubleshooting

### Common Issues:

1. **Firebase not initialized:**
   - Ensure `firebase_options.dart` is generated
   - Check that Firebase is initialized in `main.dart`

2. **Authentication errors:**
   - Verify Email/Password authentication is enabled in Firebase Console
   - Check Firebase project configuration

3. **Firestore errors:**
   - Ensure Firestore database is created
   - Check security rules
   - Verify internet connection

4. **Build errors:**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart versions
   - Verify all dependencies are compatible

### Debug Commands:

```bash
# Check Flutter installation
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check Firebase configuration
flutterfire configure
```

---

## Future Enhancements

### Planned Features:
- ✅ Email/Password Authentication
- 🔄 Google Sign-In Authentication
- 🔄 Social Media Authentication (Facebook, Apple)
- 🔄 Two-Factor Authentication
- 🔄 Biometric Authentication
- 🔄 Role-based Access Control
- 🔄 User Management Dashboard

### Google Sign-In Implementation Steps:
1. Update `google_sign_in` package to compatible version
2. Configure Google Sign-In in Firebase Console
3. Add Google Services configuration
4. Implement Google Sign-In flow
5. Test authentication flow
6. Add error handling and user feedback

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

## About

CertMobile is designed to provide a secure, user-friendly platform for digital certificate management. The authentication system ensures that only authorized users can access the platform while maintaining a smooth user experience.
