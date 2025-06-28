import 'package:flutter/material.dart';
import '../widgets/custom_navigation_bar.dart';
import '../models/user.dart';
import '../models/certificate.dart';
import 'home_page.dart';
import 'repository_page.dart';
import 'profile_page.dart';
import 'admin_dashboard_page.dart';
import 'ca_verification_page.dart';
import 'metadata_rules_page.dart';

class DashboardPage extends StatelessWidget {
  final User? currentUser;
  
  const DashboardPage({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).primaryColor;
    final isAdmin = currentUser?.isAdmin ?? false;
    final isCAVerifier = currentUser?.isCAVerifier ?? false;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isAdmin || isCAVerifier)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Hello, ${currentUser?.name ?? 'User'}!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to your certificate dashboard.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            if (isAdmin || isCAVerifier) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAdmin ? 'Administrator Access' : 'CA Verifier Access',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DashboardAction(
                  icon: Icons.add_circle_outline,
                  label: 'Add Certificate',
                  onTap: () {},
                ),
                _DashboardAction(
                  icon: Icons.folder_open,
                  label: 'Repository',
                  onTap: () {},
                ),
                if (isAdmin || isCAVerifier)
                  _DashboardAction(
                    icon: Icons.verified_user,
                    label: 'CA Verification',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const CAVerificationPage()),
                      );
                    },
                  ),
                if (isAdmin)
                  _DashboardAction(
                    icon: Icons.rule,
                    label: 'Metadata Rules',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const MetadataRulesPage()),
                      );
                    },
                  ),
                _DashboardAction(
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Recent Certificates
            Text(
              'Recent Certificates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _RecentCertificateCard(
              title: 'Flutter Developer',
              issuer: 'Coursera',
              date: 'Apr 2024',
              status: CertificateStatus.pending,
            ),
            _RecentCertificateCard(
              title: 'AWS Solutions Architect',
              issuer: 'Amazon',
              date: 'Mar 2024',
              status: CertificateStatus.approved,
            ),
            const SizedBox(height: 32),
            
            // Summary Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Total',
                      value: '12',
                      icon: Icons.verified,
                      color: accentColor,
                    ),
                    _SummaryItem(
                      label: 'Shared',
                      value: '3',
                      icon: Icons.share,
                      color: Colors.green,
                    ),
                    _SummaryItem(
                      label: 'Pending',
                      value: '2',
                      icon: Icons.hourglass_empty,
                      color: Colors.orange,
                    ),
                    if (isAdmin || isCAVerifier)
                      _SummaryItem(
                        label: 'To Review',
                        value: '5',
                        icon: Icons.pending_actions,
                        color: Colors.red,
                      ),
                  ],
                ),
              ),
            ),
            
            // Admin-specific sections
            if (isAdmin || isCAVerifier) ...[
              const SizedBox(height: 32),
              Text(
                'Admin Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AdminActionCard(
                      title: 'Review Certificates',
                      subtitle: '${isAdmin ? '5' : '3'} pending approvals',
                      icon: Icons.verified_user,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const CAVerificationPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isAdmin)
                    Expanded(
                      child: _AdminActionCard(
                        title: 'Manage Rules',
                        subtitle: 'Configure metadata validation',
                        icon: Icons.rule,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const MetadataRulesPage()),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            // Already on Dashboard, do nothing
          } else if (index == 2) {
            if (isAdmin || isCAVerifier) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CAVerificationPage()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const RepositoryPage()),
              );
            }
          } else if (index == 3) {
            if (isAdmin) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const RepositoryPage()),
              );
            }
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const RepositoryPage()),
            );
          } else if (index == 5) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
        currentUser: currentUser,
      ),
    );
  }
}

class _DashboardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DashboardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(icon, size: 28, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentCertificateCard extends StatelessWidget {
  final String title;
  final String issuer;
  final String date;
  final CertificateStatus status;
  const _RecentCertificateCard({
    required this.title,
    required this.issuer,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: ListTile(
        leading: Icon(Icons.description, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Issued by $issuer'),
            Text(date),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: status.statusColor),
              ),
              child: Text(
                status.statusDisplay,
                style: TextStyle(
                  color: status.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing:
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
        onTap: () {},
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
