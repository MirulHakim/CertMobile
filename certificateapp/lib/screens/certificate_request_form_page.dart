import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/certificate_service.dart';
import '../services/auth_service.dart';
import '../services/certificate_request_service.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:intl/intl.dart';

class CertificateRequestFormPage extends StatefulWidget {
  const CertificateRequestFormPage({super.key});

  @override
  State<CertificateRequestFormPage> createState() =>
      _CertificateRequestFormPageState();
}

class _CertificateRequestFormPageState
    extends State<CertificateRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _certNameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _recipientController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reasonController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  final CertificateService _certificateService = CertificateService();
  final AuthService _authService = AuthService();
  final CertificateRequestService _certificateRequestService =
      CertificateRequestService();

  String? _selectedType;
  String? _selectedPriority;
  File? _selectedFile;
  bool _isSubmitting = false;
  bool _isUploading = false;
  Map<String, dynamic>? _userProfile;

  final List<String> _certificateTypes = [
    'Academic',
    'Medical',
    'Training',
    'Professional',
    'Achievement',
    'Certification',
    'License',
    'Award',
    'Completion',
    'Other',
  ];

  final List<String> _priorities = [
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _userProfile = await _authService.getUserProfile(user.uid);
        // Pre-fill recipient name with current user's name
        if (_userProfile != null && _userProfile!['displayName'] != null) {
          _recipientController.text = _userProfile!['displayName'];
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _pickFile() async {
    setState(() => _isUploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path == null) {
          throw Exception('File path is null. Cannot upload.');
        }
        final file = File(path);
        if (!file.existsSync()) {
          throw Exception('Selected file does not exist.');
        }
        setState(() {
          _selectedFile = file;
        });

        // Extract metadata if it's a PDF file
        if (path.toLowerCase().endsWith('.pdf')) {
          try {
            final data = await extractCertificateData(path);
            autofillForm(data);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Certificate data extracted and form auto-filled!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            print('Error extracting PDF data: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not extract data from PDF: $e'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required fields
    if (_certNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter certificate name')),
      );
      return;
    }

    if (_issuerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter issuer name')),
      );
      return;
    }

    if (_recipientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter recipient name')),
      );
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select certificate type')),
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
      // Create request data
      final requestData = {
        'certName': _certNameController.text.trim(),
        'issuer': _issuerController.text.trim(),
        'recipientName': _recipientController.text.trim(),
        'certificateType': _selectedType!,
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'reason': _reasonController.text.trim(),
        'additionalInfo': _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
        'priority': _selectedPriority!,
        'requestedBy': _authService.currentUser?.uid ?? 'unknown',
        'requestedByEmail': _authService.currentUser?.email ?? 'unknown',
        'hasAttachment': _selectedFile != null,
      };

      // Save the request using the enhanced service with file upload
      final requestId = await _certificateRequestService.addRequest(
        requestData,
        file: _selectedFile,
      );

      if (requestId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certificate request submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to submit request');
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

  Future<Map<String, String>> extractCertificateData(String pdfPath) async {
    final text = await ReadPdfText.getPDFtext(pdfPath);
    final Map<String, String> data = {};

    // List of supported keys (lowercase, as in the PDF)
    final supportedKeys = [
      'certificate name',
      'certificate type',
      'issuer',
      'recipient',
      'expiry date',
      'description',
      'additional information',
      'reason',
    ];

    final regex = RegExp(r'([a-zA-Z ]+)\s*:\s*(.+)');
    for (final line in text.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final key = match.group(1)!.trim().toLowerCase();
        final value = match.group(2)!.trim();
        if (supportedKeys.contains(key)) {
          data[key] = value;
        }
      }
    }
    return data;
  }

  void autofillForm(Map<String, String> data) {
    _certNameController.text = data['certificate name'] ?? '';
    _issuerController.text = data['issuer'] ?? '';
    _recipientController.text = data['recipient'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _additionalInfoController.text = data['additional information'] ?? '';
    _reasonController.text = data['reason'] ?? '';

    // Certificate Type (dropdown)
    if (data['certificate type'] != null) {
      final type = data['certificate type']!.trim().toLowerCase();
      final match = _certificateTypes.firstWhere(
        (t) => t.toLowerCase() == type,
        orElse: () => '',
      );
      if (match != '') {
        _selectedType = match;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Certificate'),
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
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Submit a certificate request to the Certificate Authority for approval.',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Certificate Details Section
                    _buildSectionHeader(
                        'Certificate Details', Icons.description),
                    const SizedBox(height: 16),

                    // Certificate Name
                    TextFormField(
                      controller: _certNameController,
                      decoration: const InputDecoration(
                        labelText: 'Certificate Name *',
                        hintText: 'Enter the name of the certificate',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter certificate name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Certificate Type
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Certificate Type *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _certificateTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select certificate type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Issuer
                    TextFormField(
                      controller: _issuerController,
                      decoration: const InputDecoration(
                        labelText: 'Issuer/Organization *',
                        hintText: 'Enter the issuing organization',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter issuer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Recipient
                    TextFormField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Name *',
                        hintText: 'Enter the recipient name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter recipient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter certificate description (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Request Details Section
                    _buildSectionHeader('Request Details', Icons.assignment),
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
                        labelText: 'Reason for Request *',
                        hintText: 'Explain why you need this certificate',
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
                    const SizedBox(height: 24),

                    // Attachments Section
                    _buildSectionHeader('Attachments', Icons.attach_file),
                    const SizedBox(height: 16),

                    // File Upload
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.upload_file, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Supporting Documents',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload any supporting documents (PDF, DOC, DOCX, JPG, PNG)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 16, color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'PDF files will automatically extract certificate data and fill the form fields',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedFile != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedFile!.path.split('/').last,
                                      style:
                                          TextStyle(color: Colors.green[700]),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close,
                                        color: Colors.green[700]),
                                    onPressed: () {
                                      setState(() {
                                        _selectedFile = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _pickFile,
                            icon: _isUploading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.upload_file),
                            label: Text(
                                _isUploading ? 'Uploading...' : 'Choose File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Submit Request',
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

  @override
  void dispose() {
    _certNameController.dispose();
    _issuerController.dispose();
    _recipientController.dispose();
    _descriptionController.dispose();
    _reasonController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }
}
