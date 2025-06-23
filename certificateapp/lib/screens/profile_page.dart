import 'package:flutter/material.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'john.doe@example.com',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
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
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement logout
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // TODO: Perform logout
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                    (route) => false,
                                  );
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
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
