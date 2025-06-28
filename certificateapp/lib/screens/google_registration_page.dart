import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../main.dart';

class GoogleRegistrationPage extends StatefulWidget {
  final User user;

  const GoogleRegistrationPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<GoogleRegistrationPage> createState() => _GoogleRegistrationPageState();
}

class _GoogleRegistrationPageState extends State<GoogleRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _orgController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _customRoleController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedRole;
  bool _isLoading = false;

  final List<String> _roles = [
    'Certificate Authorities (CAs)',
    'Recipients',
    'Admin',
    'Other',
  ];

  @override
  void dispose() {
    _orgController.dispose();
    _phoneController.dispose();
    _customRoleController.dispose();
    super.dispose();
  }

  Future<void> _switchAccount() async {
    try {
      // Sign out current user
      await _authService.signOut();

      // Navigate back to welcome page to allow new account selection
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error switching account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        debugPrint('Completing Google user registration...');

        // Create user profile in Firestore with role information
        await _firestore.collection('users').doc(widget.user.uid).set({
          'uid': widget.user.uid,
          'email': widget.user.email,
          'displayName': widget.user.displayName,
          'photoURL': widget.user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'role': _selectedRole == 'Other'
              ? _customRoleController.text.trim()
              : _selectedRole!,
          'organization': _orgController.text.trim().isEmpty
              ? null
              : _orgController.text.trim(),
          'phoneNumber': _phoneController.text.trim().isEmpty
              ? widget.user.phoneNumber
              : _phoneController.text.trim(),
          'isActive': true,
          'authProvider': 'google',
          'emailVerified': widget.user.emailVerified,
          'registrationCompleted': true,
        });

        debugPrint('Google user registration completed successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration completed! Welcome to CertiSafe.'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to root and let AuthWrapper handle navigation
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            // Go back to the root of the app, AuthWrapper will show HomePage
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const AuthWrapper(),
              ),
              (route) => false,
            );
          }
        }
      } catch (e) {
        debugPrint('Registration error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again.'),
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

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with account switching
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // User avatar and account info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: accentColor.withValues(alpha: 0.2),
                          backgroundImage: widget.user.photoURL != null
                              ? NetworkImage(widget.user.photoURL!)
                              : null,
                          child: widget.user.photoURL == null
                              ? Icon(
                                  Icons.person,
                                  size: 30,
                                  color: accentColor,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.user.email ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Switch account button
                        IconButton(
                          onPressed: _switchAccount,
                          icon: const Icon(Icons.swap_horiz),
                          tooltip: 'Switch Account',
                          style: IconButton.styleFrom(
                            backgroundColor: accentColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please provide additional information to complete your registration.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Role Selection
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Your Role *',
                        prefixIcon: Icon(Icons.work_outline),
                        border: OutlineInputBorder(),
                        helperText:
                            'Select your role in the certificate system',
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
                          return 'Please select your role';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Custom Role (if "Other" is selected)
                    if (_selectedRole == 'Other') ...[
                      TextFormField(
                        controller: _customRoleController,
                        decoration: const InputDecoration(
                          labelText: 'Specify Your Role *',
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
                      const SizedBox(height: 16),
                    ],

                    // Organization
                    TextFormField(
                      controller: _orgController,
                      decoration: const InputDecoration(
                        labelText: 'Organization (Optional)',
                        prefixIcon: Icon(Icons.business_outlined),
                        border: OutlineInputBorder(),
                        helperText: 'Your company or organization name',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: const OutlineInputBorder(),
                        helperText: widget.user.phoneNumber != null
                            ? 'Current: ${widget.user.phoneNumber}'
                            : 'Add your phone number',
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegistration,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Complete Registration',
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
              const SizedBox(height: 24),

              // Information card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Why do we need this information?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your role determines what actions you can perform in the certificate system. Certificate Authorities can issue certificates, while Recipients can view and manage their certificates.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
