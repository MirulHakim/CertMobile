import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import 'debug_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'google_registration_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isGoogleSigningIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Check if user is already signed in
    try {
      final isSignedIn = await _googleAuthService.isSignedIn();
      print('WelcomePage - User already signed in with Google: $isSignedIn');

      if (isSignedIn) {
        // User is already signed in, let AuthWrapper handle navigation
        print(
            'WelcomePage - User already signed in, AuthWrapper should redirect');
      }
    } catch (e) {
      print('WelcomePage - Error checking auth state: $e');
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isGoogleSigningIn = true);
    try {
      final userCredential = await _googleAuthService.signInWithGoogle();
      if (userCredential != null) {
        // Check if user already exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final registrationCompleted =
              userData['registrationCompleted'] ?? false;
          final role = userData['role'];

          if (registrationCompleted && role != null) {
            // Account already registered and completed
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account already exists, please sign in.'),
                  backgroundColor: Colors.orange,
                ),
              );
              await FirebaseAuth.instance.signOut();
            }
          } else {
            // User exists but needs to complete registration
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GoogleRegistrationPage(user: userCredential.user!),
                ),
              );
            }
          }
        } else {
          // New user, show registration form
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GoogleRegistrationPage(user: userCredential.user!),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleSigningIn = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleSigningIn = true);
    try {
      final userCredential = await _googleAuthService.signInWithGoogle();
      if (userCredential != null) {
        // Check if user is registered
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final registrationCompleted =
              userData['registrationCompleted'] ?? false;
          final role = userData['role'];

          if (registrationCompleted && role != null) {
            // Registered and completed, let AuthWrapper show HomePage
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signed in with Google!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            // Not completed registration, show error and sign out
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Account Not Registered'),
                  content: const Text(
                    'This Google account is not registered in our system. Please use the "Continue with Google" button above to register your account.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              await FirebaseAuth.instance.signOut();
            }
          }
        } else {
          // Not registered, show error and sign out
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Account Not Registered'),
                content: const Text(
                  'This Google account is not registered in our system. Please use the "Continue with Google" button above to register your account.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            await FirebaseAuth.instance.signOut();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).primaryColor;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accentColor,
              accentColor.withOpacity(0.85),
              accentColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                // App icon/logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'CertiSafe',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Digital Certificate Repository',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Secure • Reliable • Trusted',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.white60,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 80),
                // Google Sign-In Button
                Container(
                  width: 320,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _isGoogleSigningIn ? null : _handleGoogleRegister,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isGoogleSigningIn
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black87,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/google__logo.png',
                                    height: 24,
                                    width: 24,
                                  ),
                            const SizedBox(width: 16),
                            Text(
                              _isGoogleSigningIn
                                  ? 'Signing in...'
                                  : 'Continue with Google',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Alternative options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _isGoogleSigningIn ? null : _handleGoogleRegister,
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Temporary debug button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DebugPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Debug Google Sign-In',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Features section
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Why Choose CertiSafe?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureItem(
                          Icons.security, 'Secure Authentication'),
                      _buildFeatureItem(
                          Icons.verified, 'Certificate Verification'),
                      _buildFeatureItem(Icons.share, 'Easy Sharing'),
                      _buildFeatureItem(Icons.backup, 'Cloud Backup'),
                      _buildFeatureItem(
                          Icons.admin_panel_settings, 'Role-based Access'),
                      _buildFeatureItem(Icons.analytics, 'System Analytics'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
