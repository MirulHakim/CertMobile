import 'package:flutter/material.dart';
import '../models/certificate.dart';
import '../models/user.dart';
import 'ca_verification_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Show settings
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            color: Colors.grey[100],
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildNavItem(
                  icon: Icons.dashboard,
                  title: 'Overview',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.verified_user,
                  title: 'CA Verification',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.people,
                  title: 'User Management',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.rule,
                  title: 'Metadata Rules',
                  index: 4,
                ),
                _buildNavItem(
                  icon: Icons.security,
                  title: 'Security',
                  index: 5,
                ),
                const Spacer(),
                const Divider(),
                _buildNavItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  index: 6,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return const CAVerificationPage();
      case 2:
        return _buildUserManagement();
      case 3:
        return _buildAnalytics();
      case 4:
        return _buildMetadataRules();
      case 5:
        return _buildSecurity();
      case 6:
        return _buildLogout();
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Statistics Cards
          Row(
            children: [
              Expanded(child: _StatCard(
                title: 'Total Certificates',
                value: '1,234',
                icon: Icons.description,
                color: Colors.blue,
                change: '+12%',
                changePositive: true,
              )),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'Pending Approval',
                value: '45',
                icon: Icons.pending,
                color: Colors.orange,
                change: '+5',
                changePositive: true,
              )),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'Active Users',
                value: '89',
                icon: Icons.people,
                color: Colors.green,
                change: '+3%',
                changePositive: true,
              )),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(
                title: 'System Health',
                value: '98%',
                icon: Icons.health_and_safety,
                color: Colors.green,
                change: 'Stable',
                changePositive: true,
              )),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent Activity
          Row(
            children: [
              Expanded(
                child: _buildRecentActivity(),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildQuickActions(),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // System Alerts
          _buildSystemAlerts(),
        ],
      ),
    );
  }

  Widget _StatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
    required bool changePositive,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: changePositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: changePositive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ActivityItem(
              icon: Icons.check_circle,
              title: 'Certificate Approved',
              subtitle: 'Flutter Developer Certificate by John Doe',
              time: '2 minutes ago',
              color: Colors.green,
            ),
            _ActivityItem(
              icon: Icons.person_add,
              title: 'New User Registered',
              subtitle: 'jane.smith@example.com',
              time: '15 minutes ago',
              color: Colors.blue,
            ),
            _ActivityItem(
              icon: Icons.warning,
              title: 'System Alert',
              subtitle: 'High memory usage detected',
              time: '1 hour ago',
              color: Colors.orange,
            ),
            _ActivityItem(
              icon: Icons.security,
              title: 'Security Scan',
              subtitle: 'Daily security scan completed',
              time: '2 hours ago',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _QuickActionButton(
              icon: Icons.verified_user,
              title: 'Review Pending Certificates',
              subtitle: '45 certificates waiting for approval',
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            _QuickActionButton(
              icon: Icons.people,
              title: 'Manage Users',
              subtitle: 'Add, edit, or remove user accounts',
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
            _QuickActionButton(
              icon: Icons.rule,
              title: 'Configure Rules',
              subtitle: 'Set up metadata validation rules',
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
              },
            ),
            _QuickActionButton(
              icon: Icons.analytics,
              title: 'View Analytics',
              subtitle: 'System performance and usage statistics',
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemAlerts() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'System Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AlertItem(
              severity: 'Low',
              title: 'Certificate Expiry Warning',
              message: '5 certificates will expire in the next 30 days',
              color: Colors.orange,
            ),
            _AlertItem(
              severity: 'Info',
              title: 'System Maintenance',
              message: 'Scheduled maintenance on Sunday at 2:00 AM',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagement() {
    return const Center(
      child: Text(
        'User Management - Coming Soon',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildAnalytics() {
    return const Center(
      child: Text(
        'Analytics - Coming Soon',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildMetadataRules() {
    return const Center(
      child: Text(
        'Metadata Rules - Coming Soon',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildSecurity() {
    return const Center(
      child: Text(
        'Security - Coming Soon',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildLogout() {
    return const Center(
      child: Text(
        'Logout - Coming Soon',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
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
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String severity;
  final String title;
  final String message;
  final Color color;

  const _AlertItem({
    required this.severity,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  severity,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 