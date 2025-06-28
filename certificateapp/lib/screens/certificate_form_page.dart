import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/certificate_service.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class CertificateFormPage extends StatefulWidget {
  const CertificateFormPage({super.key});

  @override
  State<CertificateFormPage> createState() => _CertificateFormPageState();
}

class _CertificateFormPageState extends State<CertificateFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _recipientController = TextEditingController();
  final _descriptionController = TextEditingController();
  final CertificateService _certificateService = CertificateService();
  DateTime? _issueDate;
  DateTime? _expiryDate;
  String? _selectedType;
  String? _certificateId;
  String? _filePath;
  File? _selectedFile;
  bool _isUploading = false;
  bool _isSaving = false;

  final List<String> _certificateTypes = [
    'Academic',
    'Medical',
    'Training',
    'Professional',
    'Achievement',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _generateCertificateId();
  }

  void _generateCertificateId() {
    setState(() {
      _certificateId = const Uuid().v4();
    });
  }

  Future<void> _pickFile() async {
    setState(() => _isUploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _filePath = result.files.single.name;
          _selectedFile = File(result.files.single.path!);
        });
        // If PDF, extract text and autofill fields
        if (_filePath != null && _filePath!.toLowerCase().endsWith('.pdf')) {
          try {
            String text = await ReadPdfText.getPDFtext(_selectedFile!.path);
            _autofillFromPdfText(text);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to extract PDF text: $e')),
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

  void _autofillFromPdfText(String text) {
    // Simple regex-based extraction for fields like 'Certificate Name:', 'Issuer:', etc.
    String? getField(String label) {
      final regex = RegExp('$label\s*:\s*(.*)', caseSensitive: false);
      final match = regex.firstMatch(text);
      return match != null ? match.group(1)?.trim() : null;
    }

    final certName = getField('Certificate Name') ?? getField('Certificate');
    final issuer = getField('Issuer');
    final recipient = getField('Recipient');
    final type = getField('Type');
    final notes = getField('Notes');
    final issueDate = getField('Issue Date');
    final expiryDate = getField('Expiry Date');

    setState(() {
      if (certName != null && certName.isNotEmpty)
        _nameController.text = certName;
      if (issuer != null && issuer.isNotEmpty) _issuerController.text = issuer;
      if (recipient != null && recipient.isNotEmpty)
        _recipientController.text = recipient;
      if (type != null && type.isNotEmpty && _certificateTypes.contains(type))
        _selectedType = type;
      if (notes != null && notes.isNotEmpty)
        _descriptionController.text = notes;
      if (issueDate != null && issueDate.isNotEmpty) {
        final parsed = DateTime.tryParse(issueDate);
        if (parsed != null) _issueDate = parsed;
      }
      if (expiryDate != null && expiryDate.isNotEmpty) {
        final parsed = DateTime.tryParse(expiryDate);
        if (parsed != null) _expiryDate = parsed;
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _saveCertificate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a certificate file')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload file to Firebase Storage
      final firebaseResult = await _certificateService.uploadFileToFirebase(
          _selectedFile!, _filePath!);
      if (firebaseResult == null) {
        throw Exception('Failed to upload file to Firebase Storage');
      }

      // Continue with local save as before
      final description = '''
Certificate: ${_nameController.text}
Issuer: ${_issuerController.text}
Recipient: ${_recipientController.text}
Type: $_selectedType
Issue Date: ${_issueDate?.toString().split(' ')[0] ?? 'Not specified'}
Expiry Date: ${_expiryDate?.toString().split(' ')[0] ?? 'Not specified'}
${_descriptionController.text.isNotEmpty ? 'Notes: $_descriptionController.text' : ''}
      '''
          .trim();

      final certificate = await _certificateService.addCertificate();

      if (certificate != null) {
        final updatedCertificate = certificate.copyWith(
          fileName: _nameController.text,
          description: description,
          category: _selectedType,
        );

        await _certificateService.updateCertificate(updatedCertificate);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Certificate created and file uploaded to Firebase!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        throw Exception('Failed to save certificate');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _recipientController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Certificate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Certificate ID Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Certificate ID',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _certificateId ?? 'Generating...',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Certificate Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Certificate Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Certificate Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter certificate name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _issuerController,
                          decoration: const InputDecoration(
                            labelText: 'Issuer',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_balance),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the issuer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _recipientController,
                          decoration: const InputDecoration(
                            labelText: 'Recipient Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter recipient name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Certificate Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: _certificateTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedType = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a certificate type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Additional Notes (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.note),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Dates Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dates',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Issue Date'),
                          subtitle: Text(
                            _issueDate == null
                                ? 'Select issue date'
                                : '${_issueDate!.year}-${_issueDate!.month.toString().padLeft(2, '0')}-${_issueDate!.day.toString().padLeft(2, '0')}',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => _selectDate(context, true),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Expiry Date'),
                          subtitle: Text(
                            _expiryDate == null
                                ? 'Select expiry date'
                                : '${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => _selectDate(context, false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // File Upload Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Certificate File',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _isUploading ? null : _pickFile,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _filePath != null
                                      ? Icons.check_circle
                                      : Icons.upload_file,
                                  color: _filePath != null
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _filePath ?? 'Upload PDF or Image',
                                    style: TextStyle(
                                      color: _filePath != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                if (_isUploading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveCertificate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Create Certificate',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
