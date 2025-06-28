import 'package:flutter/material.dart';
import '../models/certificate.dart';
import '../models/user.dart';

class CAVerificationPage extends StatefulWidget {
  const CAVerificationPage({Key? key}) : super(key: key);

  @override
  State<CAVerificationPage> createState() => _CAVerificationPageState();
}

class _CAVerificationPageState extends State<CAVerificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Under Review', 'Approved', 'Rejected'];

  // Mock data - replace with actual data from your service
  final List<Certificate> _certificates = [
    Certificate(
      id: 1,
      fileName: 'Flutter_Developer_Certificate.pdf',
      filePath: '/path/to/file1.pdf',
      fileType: 'pdf',
      fileSize: 1024 * 1024, // 1MB
      uploadDate: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Flutter Development Certification',
      category: 'Programming',
      status: CertificateStatus.pending,
      issuerName: 'Coursera',
      issuerId: 'CRS001',
      issueDate: DateTime.now().subtract(const Duration(days: 30)),
      expiryDate: DateTime.now().add(const Duration(days: 335)),
      certificateNumber: 'FLT-2024-001',
      metadataHash: 'abc123def456',
      digitalSignature: 'sig123',
    ),
    Certificate(
      id: 2,
      fileName: 'AWS_Solutions_Architect.pdf',
      filePath: '/path/to/file2.pdf',
      fileType: 'pdf',
      fileSize: 2048 * 1024, // 2MB
      uploadDate: DateTime.now().subtract(const Duration(days: 1)),
      description: 'AWS Solutions Architect Associate',
      category: 'Cloud Computing',
      status: CertificateStatus.underReview,
      issuerName: 'Amazon Web Services',
      issuerId: 'AWS001',
      issueDate: DateTime.now().subtract(const Duration(days: 15)),
      expiryDate: DateTime.now().add(const Duration(days: 350)),
      certificateNumber: 'AWS-2024-002',
      metadataHash: 'def456ghi789',
      digitalSignature: 'sig456',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Certificate> get filteredCertificates {
    if (_selectedFilter == 'All') {
      return _certificates;
    }
    return _certificates.where((cert) {
      switch (_selectedFilter) {
        case 'Pending':
          return cert.status == CertificateStatus.pending;
        case 'Under Review':
          return cert.status == CertificateStatus.underReview;
        case 'Approved':
          return cert.status == CertificateStatus.approved;
        case 'Rejected':
          return cert.status == CertificateStatus.rejected;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CA Verification'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pending Review'),
            Tab(text: 'Under Review'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filter: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _filters.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCertificateList(filteredCertificates.where((c) => 
                  c.status == CertificateStatus.pending).toList()),
                _buildCertificateList(filteredCertificates.where((c) => 
                  c.status == CertificateStatus.underReview).toList()),
                _buildCertificateList(filteredCertificates.where((c) => 
                  c.status == CertificateStatus.approved || 
                  c.status == CertificateStatus.rejected).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateList(List<Certificate> certificates) {
    if (certificates.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No certificates found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: certificates.length,
      itemBuilder: (context, index) {
        final certificate = certificates[index];
        return _CertificateVerificationCard(
          certificate: certificate,
          onApprove: () => _showApprovalDialog(certificate),
          onReject: () => _showRejectionDialog(certificate),
          onReview: () => _showReviewDialog(certificate),
        );
      },
    );
  }

  void _showApprovalDialog(Certificate certificate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to approve "${certificate.fileName}"?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Verification Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement approval logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certificate approved successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(Certificate certificate) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${certificate.fileName}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a rejection reason')),
                );
                return;
              }
              // TODO: Implement rejection logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certificate rejected')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(Certificate certificate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Certificate Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('File Name', certificate.fileName),
              _DetailRow('Issuer', certificate.issuerName ?? 'N/A'),
              _DetailRow('Certificate Number', certificate.certificateNumber ?? 'N/A'),
              _DetailRow('Issue Date', certificate.issueDate?.toString().split(' ')[0] ?? 'N/A'),
              _DetailRow('Expiry Date', certificate.expiryDate?.toString().split(' ')[0] ?? 'N/A'),
              _DetailRow('File Size', certificate.formattedFileSize),
              _DetailRow('Status', certificate.status.statusDisplay),
              _DetailRow('Metadata Hash', certificate.metadataHash ?? 'N/A'),
              const SizedBox(height: 16),
              const Text(
                'Verification Actions:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showApprovalDialog(certificate);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showRejectionDialog(certificate);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _CertificateVerificationCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onReview;

  const _CertificateVerificationCard({
    required this.certificate,
    required this.onApprove,
    required this.onReject,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        certificate.issuerName ?? 'Unknown Issuer',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: certificate.status.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: certificate.status.statusColor),
                  ),
                  child: Text(
                    certificate.status.statusDisplay,
                    style: TextStyle(
                      color: certificate.status.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.calendar_today,
                    label: certificate.issueDate?.toString().split(' ')[0] ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.file_copy,
                    label: certificate.formattedFileSize,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.category,
                    label: certificate.category ?? 'N/A',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.visibility),
                    label: const Text('Review'),
                  ),
                ),
                const SizedBox(width: 8),
                if (certificate.status == CertificateStatus.pending)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (certificate.status == CertificateStatus.pending) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 