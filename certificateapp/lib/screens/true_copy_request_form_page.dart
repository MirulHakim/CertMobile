import 'package:flutter/material.dart';
import '../services/certificate_service.dart';
import '../services/auth_service.dart';
import '../services/certificate_request_service.dart';
import '../models/certificate.dart';

class TrueCopyRequestFormPage extends StatefulWidget {
  const TrueCopyRequestFormPage({super.key});

  @override
  State<TrueCopyRequestFormPage> createState() =>
      _TrueCopyRequestFormPageState();
}

class _TrueCopyRequestFormPageState extends State<TrueCopyRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  final CertificateService _certificateService = CertificateService();
  final AuthService _authService = AuthService();
  final CertificateRequestService _certificateRequestService =
      CertificateRequestService();

  List<Certificate> _userCertificates = [];
  Certificate? _selectedCertificate;
  String? _selectedPriority;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<String> _priorities = [
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserCertificates();
  }

  Future<void> _loadUserCertificates() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final certificates = await _certificateService.getAllCertificates();
        // Filter certificates for current user (assuming recipient name matches user profile)
        final userProfile = await _authService.getUserProfile(user.uid);
        final userName = userProfile?['displayName'] ?? '';

        setState(() {
          _userCertificates = certificates
              .where((cert) =>
                  cert.recipientName
                      .toLowerCase()
                      .contains(userName.toLowerCase()) ||
                  cert.recipientName.toLowerCase().contains('recipient'))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading certificates: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCertificate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a certificate')),
      );
      return;
    }

    if (_selectedPriority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select priority level')),
      );
      return;
    }

    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide a reason for the request')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create true copy request data
      final requestData = {
        'requestType': 'true_copy',
        'originalCertificateId': _selectedCertificate!.certId,
        'certName': _selectedCertificate!.certName,
        'certificateType': _selectedCertificate!.certificateType,
        'issuer': _selectedCertificate!.issuer,
        'recipientName': _selectedCertificate!.recipientName,
        'reason': _reasonController.text.trim(),
        'additionalInfo': _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
        'priority': _selectedPriority!,
        'requestedBy': _authService.currentUser?.uid ?? 'unknown',
        'hasAttachment': false,
      };

      // Save the request using the service
      await _certificateRequestService.addRequest(requestData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('True copy request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request True Copy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Submitting your request...'),
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.copy, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Request an official copy of your existing certificate.',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Certificate Selection Section
                        _buildSectionHeader(
                            'Select Certificate', Icons.description),
                        const SizedBox(height: 16),

                        if (_userCertificates.isEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'No certificates found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'You need to have existing certificates to request true copies.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Certificate Dropdown
                          DropdownButtonFormField<Certificate>(
                            value: _selectedCertificate,
                            decoration: const InputDecoration(
                              labelText: 'Select Certificate *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.verified_user),
                            ),
                            items: _userCertificates.map((cert) {
                              return DropdownMenuItem(
                                value: cert,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      cert.certName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '${cert.certificateType} - ${cert.issuer}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCertificate = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a certificate';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Certificate Details Card
                          if (_selectedCertificate != null) ...[
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Certificate Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                        'ID', _selectedCertificate!.certId),
                                    _buildDetailRow('Type',
                                        _selectedCertificate!.certificateType),
                                    _buildDetailRow(
                                        'Issuer', _selectedCertificate!.issuer),
                                    _buildDetailRow('Recipient',
                                        _selectedCertificate!.recipientName),
                                    _buildDetailRow(
                                        'Issue Date',
                                        _selectedCertificate!
                                            .formattedIssueDate),
                                    _buildDetailRow(
                                        'Status',
                                        _selectedCertificate!.status
                                            .toUpperCase()),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],

                        // Request Details Section
                        _buildSectionHeader(
                            'Request Details', Icons.assignment),
                        const SizedBox(height: 16),

                        // Priority
                        DropdownButtonFormField<String>(
                          value: _selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority Level *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.priority_high),
                          ),
                          items: _priorities.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select priority level';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Reason
                        TextFormField(
                          controller: _reasonController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Reason for True Copy Request *',
                            hintText:
                                'Explain why you need a true copy (e.g., lost original, multiple copies needed)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.help_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please provide a reason for the request';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Additional Information
                        TextFormField(
                          controller: _additionalInfoController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Additional Information',
                            hintText: 'Any additional details (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.note_add),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _userCertificates.isEmpty
                                ? null
                                : _submitRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Submit True Copy Request',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }
}
