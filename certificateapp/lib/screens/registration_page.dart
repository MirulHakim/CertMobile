import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import 'login_page.dart';
import 'welcome_page.dart';
import 'google_registration_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _orgController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _customRoleController = TextEditingController();
  final _authService = AuthService();
  final _googleAuthService = GoogleAuthService();

  String? _selectedRole;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleSigningIn = false;

  final List<String> _roles = [
    'Certificate Authorities (CAs)',
    'Recipients',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _orgController.dispose();
    _phoneController.dispose();
    _customRoleController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        debugPrint('Starting registration process...');
        // Create user with email and password
        final userCredential =
            await _authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        debugPrint('User created successfully: \\${userCredential.user?.uid}');

        // Update user profile with additional information
        await _authService.updateUserProfile(
          uid: userCredential.user!.uid,
          fullName: _nameController.text.trim(),
          role: _selectedRole == 'Other'
              ? _customRoleController.text.trim()
              : _selectedRole!,
          organization: _orgController.text.trim().isEmpty
              ? null
              : _orgController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

        debugPrint('User profile updated successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Welcome to CertMobile.'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to welcome page after successful registration
          await Future.delayed(
              const Duration(seconds: 1)); // Show success message briefly
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const WelcomePage()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        debugPrint('Registration error: $e');
        if (mounted) {
          String errorMessage = 'Registration failed. Please try again.';

          if (e.toString().contains('email-already-in-use')) {
            errorMessage = 'An account with this email already exists.';
          } else if (e.toString().contains('weak-password')) {
            errorMessage =
                'Password is too weak. Please choose a stronger password.';
          } else if (e.toString().contains('invalid-email')) {
            errorMessage = 'Invalid email address.';
          } else if (e.toString().contains('operation-not-allowed')) {
            errorMessage = 'Email/password accounts are not enabled.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleSigningIn = true;
    });

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
            // Account already exists and completed
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account already exists, please sign in.'),
                  backgroundColor: Colors.orange,
                ),
              );
              await _authService.signOut();
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
          // New user, redirect to Google registration page
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In was cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Google Sign-In failed. Please try again.';
        if (e.toString().contains('network_error')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (e.toString().contains('sign_in_canceled')) {
          errorMessage = 'Sign-in was cancelled.';
        } else if (e.toString().contains('sign_in_failed')) {
          errorMessage = 'Sign-in failed. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).primaryColor;
    final gradientColors = [
      Theme.of(context).primaryColor,
      Theme.of(context).primaryColor.withOpacity(0.8),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top wave/curve
          SizedBox(
            width: double.infinity,
            height: 220,
            child: CustomPaint(
              painter: _TopWavePainter(gradientColors),
            ),
          ),
          // Back button
          Positioned(
            top: 24,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 28),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                  (route) => false,
                );
              },
              tooltip: 'Back',
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // App icon/logo
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.15),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.verified_user,
                        size: 48,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CERTMOBILE',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Google Sign-In Button (at the top)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        icon: _isGoogleSigningIn
                            ? const SizedBox(
                                width: 20,
                                height: 20,
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
                        label: Text(
                          _isGoogleSigningIn
                              ? 'Creating account...'
                              : 'Continue with Google',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        onPressed:
                            _isGoogleSigningIn ? null : _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Registration Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              prefixIcon: Icon(Icons.work_outline),
                              border: OutlineInputBorder(),
                            ),
                            items: _roles.map((String role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a role';
                              }
                              return null;
                            },
                          ),
                          if (_selectedRole == 'Other') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _customRoleController,
                              decoration: const InputDecoration(
                                labelText: 'Specify Your Role',
                                prefixIcon: Icon(Icons.edit_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please specify your role';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _orgController,
                            decoration: const InputDecoration(
                              labelText: 'Organization (Optional)',
                              prefixIcon: Icon(Icons.business_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number (Optional)',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _handleRegistration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the top wave/curve
class _TopWavePainter extends CustomPainter {
  final List<Color> colors;
  _TopWavePainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.85,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.55,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
