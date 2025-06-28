import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/certificate.dart';
import '../services/certificate_service.dart';
import 'certificate_form_page.dart';
import 'package:share_plus/share_plus.dart';

class RepositoryPage extends StatefulWidget {
  const RepositoryPage({super.key});

  @override
  State<RepositoryPage> createState() => _RepositoryPageState();
}

class _RepositoryPageState extends State<RepositoryPage> {
  final CertificateService _certificateService = CertificateService();
  final TextEditingController _searchController = TextEditingController();
  List<Certificate> _certificates = [];
  List<Certificate> _filteredCertificates = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final certificates = await _certificateService.getAllCertificates();
      setState(() {
        _certificates = certificates;
        _filteredCertificates = certificates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading certificates: $e');
    }
  }

  void _filterCertificates(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCertificates = _certificates;
      } else {
        _filteredCertificates = _certificates.where((cert) {
          return cert.certName.toLowerCase().contains(query.toLowerCase()) ||
              cert.recipientName.toLowerCase().contains(query.toLowerCase()) ||
              cert.issuer.toLowerCase().contains(query.toLowerCase()) ||
              cert.certId.toLowerCase().contains(query.toLowerCase()) ||
              (cert.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              cert.certificateType.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _addCertificate() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CertificateFormPage(),
        ),
      );
      if (result == true) {
        await _loadCertificates();
        _showSuccessSnackBar('Certificate created successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating certificate: $e');
    }
  }

  Future<void> _deleteCertificate(Certificate certificate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content:
            Text('Are you sure you want to delete "${certificate.certName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success =
            await _certificateService.deleteCertificate(certificate.id!);
        if (success) {
          await _loadCertificates();
          _showSuccessSnackBar('Certificate deleted successfully!');
        } else {
          _showErrorSnackBar('Failed to delete certificate');
        }
      } catch (e) {
        _showErrorSnackBar('Error deleting certificate: $e');
      }
    }
  }

  void _showCertificateDetails(Certificate certificate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CertificateDetailsSheet(certificate: certificate),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Repository'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCertificate,
            tooltip: 'Add Certificate',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search certificates...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterCertificates('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterCertificates,
            ),
          ),
          // Certificate List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCertificates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No certificates found'
                                  : 'No certificates match your search',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to add your first certificate',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCertificates,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredCertificates.length,
                          itemBuilder: (context, index) {
                            final certificate = _filteredCertificates[index];
                            return CertificateCard(
                              certificate: certificate,
                              onTap: () => _showCertificateDetails(certificate),
                              onDelete: () => _deleteCertificate(certificate),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(certificate.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  certificate.isAutoGenerated
                      ? Icons.auto_awesome
                      : Icons.upload_file,
                  color: _getStatusColor(certificate.status),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.certName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${certificate.certificateType} • ${certificate.formattedIssueDate}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recipient: ${certificate.recipientName}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(certificate.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        certificate.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(certificate.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
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
            ],
          ),
        ),
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
}

class CertificateDetailsSheet extends StatelessWidget {
  final Certificate certificate;

  const CertificateDetailsSheet({
    super.key,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(certificate.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  certificate.isAutoGenerated
                      ? Icons.auto_awesome
                      : Icons.upload_file,
                  color: _getStatusColor(certificate.status),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.certName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      certificate.certificateType,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Certificate ID', certificate.certId),
          _buildDetailRow('Recipient', certificate.recipientName),
          _buildDetailRow('Issuer', certificate.issuer),
          _buildDetailRow('Type', certificate.certificateType),
          _buildDetailRow('Status', certificate.status.toUpperCase()),
          _buildDetailRow('Issue Date', certificate.formattedIssueDate),
          if (certificate.formattedExpiryDate != null)
            _buildDetailRow('Expiry Date', certificate.formattedExpiryDate!),
          if (certificate.description != null)
            _buildDetailRow('Description', certificate.description!),
          if (certificate.additionalInfo != null)
            _buildDetailRow('Additional Info', certificate.additionalInfo!),
          if (certificate.signature != null)
            _buildDetailRow('Signature', certificate.signature!),
          _buildDetailRow('Created By', certificate.createdByEmail),
          _buildDetailRow('Created At',
              DateFormat('MMM dd, yyyy HH:mm').format(certificate.createdAt)),
          _buildDetailRow('Generation Type',
              certificate.isAutoGenerated ? 'Auto-Generated' : 'Manual Upload'),
          if (certificate.fileName != null) ...[
            _buildDetailRow('File Name', certificate.fileName!),
            _buildDetailRow('File Size', certificate.formattedFileSize),
          ],
          if (certificate.fileUrl != null &&
              certificate.fileUrl!.isNotEmpty) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = certificate.fileUrl!;
                  final fileName = certificate.fileName ?? 'certificate_file';
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
                          content:
                              Text('Could not open file: \\${result.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (contextMounted) Navigator.of(context).pop();
                    if (contextMounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error downloading/opening file: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Download/View PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final url = certificate.fileUrl!;
                  await Share.share('Here is the certificate PDF link: $url');
                },
                icon: const Icon(Icons.share),
                label: const Text('Share PDF Link'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
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
}
