import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/certificate_service.dart';
import '../models/certificate.dart';
import 'certificate_form_page.dart';
import 'welcome_page.dart';
import '../services/admin_auth_service.dart';
import 'profile_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final CertificateService _certificateService = CertificateService();
  final AdminAuthService _adminAuthService = AdminAuthService();
  List<Certificate> _certificates = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'all';
  String _filterStatus = 'all';

  // Admin monitoring data
  Map<String, dynamic> _adminMonitoringData = {
    'activeUsers': 0,
    'recentActivities': [],
    'systemHealth': 'Good',
    'lastBackup': DateTime.now().subtract(const Duration(hours: 2)),
  };

  // CA Verification data
  List<Map<String, dynamic>> _caVerificationData = [
    {
      'certId': 'CERT-2401-1234',
      'status': 'Verified',
      'verificationDate': DateTime.now().subtract(const Duration(days: 1)),
      'verifiedBy': 'Admin User',
    },
    {
      'certId': 'CERT-2401-1235',
      'status': 'Pending',
      'verificationDate': null,
      'verifiedBy': null,
    },
  ];

  // Metadata rules
  List<Map<String, dynamic>> _metadataRules = [
    {
      'ruleName': 'Certificate Name Validation',
      'description': 'Certificate names must be alphanumeric and 3-50 characters',
      'enabled': true,
      'severity': 'High',
    },
    {
      'ruleName': 'File Size Limit',
      'description': 'Certificate files must be under 10MB',
      'enabled': true,
      'severity': 'Medium',
    },
    {
      'ruleName': 'Expiry Date Validation',
      'description': 'Expiry dates must be in the future',
      'enabled': true,
      'severity': 'High',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final certificates = await _certificateService.getAllCertificates();
      final stats = await _certificateService.getCertificateStats();

      setState(() {
        _certificates = certificates;
        _stats = stats;
      });
    } catch (e) {
      debugPrint('Error loading admin dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _adminAuthService.signOutAdmin();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomePage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  List<Certificate> get _filteredCertificates {
    return _certificates.where((cert) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          cert.certName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cert.recipientName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          cert.issuer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cert.certId.toLowerCase().contains(_searchQuery.toLowerCase());

      // Type filter
      final matchesType =
          _filterType == 'all' || cert.certificateType == _filterType;

      // Status filter
      final matchesStatus =
          _filterStatus == 'all' || cert.status == _filterStatus;

      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    _buildStatsCards(),
                    const SizedBox(height: 24),

                    // Admin Features Section
                    _buildAdminFeaturesSection(),
                    const SizedBox(height: 24),

                    // Search and Filters
                    _buildSearchAndFilters(),
                    const SizedBox(height: 16),

                    // Certificates List
                    _buildCertificatesList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CertificateFormPage(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Certificate'),
        backgroundColor: accentColor,
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Certificates',
          _stats['total']?.toString() ?? '0',
          Icons.verified_user,
          Colors.blue,
        ),
        _buildStatCard(
          'Active',
          _stats['active']?.toString() ?? '0',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Auto-Generated',
          _stats['autoGenerated']?.toString() ?? '0',
          Icons.auto_awesome,
          Colors.orange,
        ),
        _buildStatCard(
          'Manual Upload',
          _stats['manualUpload']?.toString() ?? '0',
          Icons.upload_file,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Administrative Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                'CA Verification',
                Icons.verified_user,
                Colors.blue,
                '${_caVerificationData.length} certificates',
                () => _showCAVerificationDialog(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                'Admin Monitoring',
                Icons.monitor,
                Colors.green,
                '${_adminMonitoringData['activeUsers']} active users',
                () => _showAdminMonitoringDialog(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                'Metadata Rules',
                Icons.rule,
                Colors.orange,
                '${_metadataRules.length} active rules',
                () => _showMetadataRulesDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color, String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Certificates',
                hintText: 'Search by name, recipient, issuer, or ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: 'all', child: Text('All Types')),
                      ...[
                        'Academic',
                        'Medical',
                        'Training',
                        'Professional',
                        'Achievement',
                        'Certification',
                        'License',
                        'Award',
                        'Completion',
                        'Other'
                      ].map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                          value: 'expired', child: Text('Expired')),
                      DropdownMenuItem(
                          value: 'revoked', child: Text('Revoked')),
                      DropdownMenuItem(
                          value: 'pending', child: Text('Pending')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesList() {
    final filteredCerts = _filteredCertificates;

    if (filteredCerts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No certificates found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificates (${filteredCerts.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredCerts.length,
          itemBuilder: (context, index) {
            final cert = filteredCerts[index];
            return _buildCertificateCard(cert);
          },
        ),
      ],
    );
  }

  Widget _buildCertificateCard(Certificate cert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(cert.status),
          child: Icon(
            cert.isAutoGenerated ? Icons.auto_awesome : Icons.upload_file,
            color: Colors.white,
          ),
        ),
        title: Text(
          cert.certName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${cert.certId}'),
            Text('Recipient: ${cert.recipientName}'),
            Text('Issuer: ${cert.issuer}'),
            Text('Type: ${cert.certificateType}'),
            Text('Status: ${cert.status.toUpperCase()}'),
            Text('Created: ${cert.formattedIssueDate}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCertificateAction(value, cert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            if (cert.status == 'active')
              const PopupMenuItem(
                value: 'revoke',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Revoke', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.orange;
      case 'revoked':
        return Colors.red;
      case 'pending':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleCertificateAction(String action, Certificate cert) async {
    switch (action) {
      case 'view':
        _showCertificateDetails(cert);
        break;
      case 'edit':
        // TODO: Implement edit functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit functionality coming soon')),
        );
        break;
      case 'revoke':
        await _revokeCertificate(cert);
        break;
      case 'delete':
        await _deleteCertificate(cert);
        break;
    }
  }

  void _showCertificateDetails(Certificate cert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cert.certName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Certificate ID', cert.certId),
              _buildDetailRow('Recipient', cert.recipientName),
              _buildDetailRow('Issuer', cert.issuer),
              _buildDetailRow('Type', cert.certificateType),
              _buildDetailRow('Status', cert.status.toUpperCase()),
              _buildDetailRow('Issue Date', cert.formattedIssueDate),
              if (cert.formattedExpiryDate != null)
                _buildDetailRow('Expiry Date', cert.formattedExpiryDate!),
              if (cert.description != null)
                _buildDetailRow('Description', cert.description!),
              if (cert.additionalInfo != null)
                _buildDetailRow('Additional Info', cert.additionalInfo!),
              if (cert.signature != null)
                _buildDetailRow('Signature', cert.signature!),
              _buildDetailRow('Created By', cert.createdByEmail),
              _buildDetailRow(
                  'Created At', cert.createdAt.toString().split('.')[0]),
              _buildDetailRow('Generation Type',
                  cert.isAutoGenerated ? 'Auto-Generated' : 'Manual Upload'),
              if (cert.fileName != null) ...[
                _buildDetailRow('File Name', cert.fileName!),
                _buildDetailRow('File Size', cert.formattedFileSize),
              ],
              if (cert.fileUrl != null && cert.fileUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = cert.fileUrl!;
                      final fileName = cert.fileName ?? 'certificate_file';
                      final contextMounted = context.mounted;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                      try {
                        final tempDir = await getTemporaryDirectory();
                        final filePath = '${tempDir.path}/$fileName';
                        await Dio().download(url, filePath);
                        if (contextMounted) Navigator.of(context).pop();
                        final result = await OpenFile.open(filePath);
                        if (result.type != ResultType.done && contextMounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Could not open file: \\${result.message}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (contextMounted) Navigator.of(context).pop();
                        if (contextMounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Error downloading/opening file: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download/View File'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(value),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> _revokeCertificate(Certificate cert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Certificate'),
        content: Text('Are you sure you want to revoke "${cert.certName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _certificateService.updateCertificateStatus(
            cert.id!, 'revoked');
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certificate revoked successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        } else {
          throw Exception('Failed to revoke certificate');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error revoking certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCertificate(Certificate cert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content: Text(
            'Are you sure you want to delete "${cert.certName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _certificateService.deleteCertificate(cert.id!);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certificate deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        } else {
          throw Exception('Failed to delete certificate');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCAVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CA Verification'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Certificate Authority Verification Status'),
              const SizedBox(height: 16),
              ..._caVerificationData.map((cert) => Card(
                child: ListTile(
                  title: Text(cert['certId']),
                  subtitle: Text('Status: ${cert['status']}'),
                  trailing: Icon(
                    cert['status'] == 'Verified' ? Icons.check_circle : Icons.pending,
                    color: cert['status'] == 'Verified' ? Colors.green : Colors.orange,
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAdminMonitoringDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Monitoring'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMonitoringItem('Active Users', '${_adminMonitoringData['activeUsers']}'),
              _buildMonitoringItem('System Health', _adminMonitoringData['systemHealth']),
              _buildMonitoringItem('Last Backup', _formatDateTime(_adminMonitoringData['lastBackup'])),
              const SizedBox(height: 16),
              const Text('Recent Activities', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('No recent activities to display'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMetadataRulesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Metadata Rules'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Active Metadata Validation Rules'),
              const SizedBox(height: 16),
              ..._metadataRules.map((rule) => Card(
                child: ListTile(
                  title: Text(rule['ruleName']),
                  subtitle: Text(rule['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(rule['severity']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          rule['severity'],
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: rule['enabled'],
                        onChanged: (value) {
                          setState(() {
                            rule['enabled'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
