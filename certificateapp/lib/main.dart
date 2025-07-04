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
import 'screens/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Certificate Directory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Waiting for Firebase to load user
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is signed in
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage(); // This will be our main page that handles user routing
        }

        // If no user is signed in
        return const WelcomePage();
      },
    );
  }
}

// Main page that handles user routing based on their role
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser == null) {
        await FirebaseAuth.instance.signOut();
        return;
      }

      // Get user data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        return;
      }

      _userData = doc.data()!;
      final registrationCompleted =
          _userData!['registrationCompleted'] ?? false;
      final role = _userData!['role']?.toString().toLowerCase();

      // If Google user hasn't completed registration, show registration page
      if (!registrationCompleted && _userData!['authProvider'] == 'google') {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => GoogleRegistrationPage(user: _currentUser!),
            ),
          );
        }
        return;
      }

      // If user has no role, sign out
      if (role == null || role.isEmpty) {
        await FirebaseAuth.instance.signOut();
        return;
      }
    } catch (e) {
      await FirebaseAuth.instance.signOut();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null || _userData == null) {
      return const WelcomePage();
    }

    final role = _userData!['role']?.toString().toLowerCase();

    // Route based on role
    if (role == 'recipients') {
      return const RecipientDashboardPage();
    } else if (role == 'certificate authorities (cas)') {
      return const CADashboardPage();
    } else if (role == 'client') {
      return const ClientDashboardPage();
    } else if (role == 'admin') {
      return const AdminDashboardPage();
    } else {
      return const RecipientDashboardPage(); // Default to recipient dashboard
    }
  }
}
