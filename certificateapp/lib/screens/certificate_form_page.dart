import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

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
  DateTime? _issueDate;
  DateTime? _expiryDate;
  String? _selectedType;
  String? _certificateId;
  String? _filePath;
  bool _isUploading = false;

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
    try {
      setState(() => _isUploading = true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _filePath = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
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

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _recipientController.dispose();
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
                                : '${_issueDate!.year}-${_issueDate!.month}-${_issueDate!.day}',
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
                                : '${_expiryDate!.year}-${_expiryDate!.month}-${_expiryDate!.day}',
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
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_filePath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please upload a certificate file'),
                          ),
                        );
                        return;
                      }
                      // TODO: Implement certificate creation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Certificate created successfully!'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Create Certificate',
                    style: TextStyle(fontSize: 16),
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
