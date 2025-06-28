import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'welcome_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _printUserInfo();
  }

  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      _currentUser = _authService.currentUser;
      if (_currentUser != null) {
        _userProfile = await _authService.getUserProfile(_currentUser!.uid);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _printUserInfo() {
    final currentUser = FirebaseAuth.instance.currentUser;
    debugPrint('ProfilePage - Current Firebase user: \\${currentUser?.email}');
    debugPrint('ProfilePage - Current Firebase user ID: \\${currentUser?.uid}');
    _checkGoogleSignIn();
  }

  Future<void> _checkGoogleSignIn() async {
    try {
      final isGoogleSignedIn = await GoogleSignIn().isSignedIn();
      debugPrint('ProfilePage - Is Google signed in: \\${isGoogleSignedIn}');
    } catch (e) {
      debugPrint('ProfilePage - Error checking auth state: \\${e}');
    }
  }

  Future<void> _handleLogout() async {
    try {
      print('ProfilePage: Starting logout process...');

      await AuthService().signOut();

      print('ProfilePage: Logout completed successfully');
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // AuthWrapper will automatically detect the sign-out and navigate to WelcomePage
        // No need for manual navigation
      }
    } catch (e) {
      print('ProfilePage: Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit profile
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          backgroundImage: _currentUser?.photoURL != null
                              ? NetworkImage(_currentUser!.photoURL!)
                              : null,
                          child: _currentUser?.photoURL == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(context).primaryColor,
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userProfile?['displayName'] ??
                              _currentUser?.displayName ??
                              'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _currentUser?.email ?? 'No email',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        if (_userProfile?['role'] != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _userProfile!['role'],
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Profile Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ProfileOptionCard(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          subtitle: 'Update your personal details',
                          onTap: () {
                            // TODO: Navigate to personal info page
                          },
                        ),
                        ProfileOptionCard(
                          icon: Icons.security,
                          title: 'Security',
                          subtitle: 'Change password and security settings',
                          onTap: () {
                            // TODO: Navigate to security page
                          },
                        ),
                        ProfileOptionCard(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          onTap: () {
                            // TODO: Navigate to notifications page
                          },
                        ),
                        ProfileOptionCard(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: 'Change app language',
                          onTap: () {
                            // TODO: Navigate to language settings
                          },
                        ),
                        ProfileOptionCard(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'Get help and contact support',
                          onTap: () {
                            // TODO: Navigate to help page
                          },
                        ),
                        ProfileOptionCard(
                          icon: Icons.info_outline,
                          title: 'About',
                          subtitle: 'App version and information',
                          onTap: () {
                            // TODO: Navigate to about page
                          },
                        ),
                        const SizedBox(height: 16),
                        // Debug button (temporary)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _printUserInfo,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.orange),
                            ),
                            child: const Text(
                              'Debug: Check Auth State',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text(
                                      'Are you sure you want to logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _handleLogout();
                                      },
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ProfileOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
