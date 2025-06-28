import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/welcome_page.dart';
import 'screens/google_registration_page.dart';
import 'screens/ca_dashboard_page.dart';
import 'screens/recipient_dashboard_page.dart';
import 'screens/client_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Always sign out user on app start
  await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Certificate Directory',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getHomePage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const WelcomePage();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Check if user exists and has completed registration
      if (!doc.exists) {
        // User doesn't exist in Firestore, redirect to welcome page
        await FirebaseAuth.instance.signOut();
        return const WelcomePage();
      }

      final userData = doc.data()!;
      final registrationCompleted = userData['registrationCompleted'] ?? false;
      final role = userData['role']?.toString().toLowerCase();

      // If Google user hasn't completed registration, show registration page
      if (!registrationCompleted && userData['authProvider'] == 'google') {
        return GoogleRegistrationPage(user: user);
      }

      // If user has no role, redirect to welcome page
      if (role == null || role.isEmpty) {
        await FirebaseAuth.instance.signOut();
        return const WelcomePage();
      }

      // Route based on role
      if (role == 'recipients') {
        return const RecipientDashboardPage();
      } else if (role == 'certificate authorities (cas)') {
        return const CADashboardPage();
      } else if (role == 'client') {
        return const ClientDashboardPage();
      } else {
        return const RecipientDashboardPage(); // Default to recipient dashboard
      }
    } catch (e) {
      debugPrint('Error checking user data: $e');
      // On error, sign out and redirect to welcome page
      await FirebaseAuth.instance.signOut();
      return const WelcomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<Widget>(
            future: _getHomePage(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.data!;
            },
          );
        }
        return const WelcomePage();
      },
    );
  }
}
