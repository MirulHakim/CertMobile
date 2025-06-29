import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/certificate_request_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  final AuthService _authService = AuthService();
  final CertificateRequestService _certificateRequestService =
      CertificateRequestService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _setupRealtimeListener();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user != null) {
        _requests =
            await _certificateRequestService.getRequestsByUser(user.uid);
      } else {
        _requests = [];
      }
    } catch (e) {
      print('Error loading requests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading requests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Set up real-time listener for requests
  void _setupRealtimeListener() {
    final user = _authService.currentUser;
    if (user != null) {
      print('Setting up real-time listener for user: ${user.uid}');
      _certificateRequestService.getUserRequestsStream(user.uid).listen(
        (requests) {
          print('Received ${requests.length} requests from Firebase');
          if (mounted) {
            setState(() {
              _requests = requests;
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          print('Error in real-time listener: $error');
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading requests: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } else {
      print('No user found, cannot set up real-time listener');
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'in_progress':
        return 'In Progress';
      default:
        return 'Unknown';
    }
  }

  // Manual refresh method
  Future<void> _manualRefresh() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Force refresh by getting data directly
        final requests =
            await _certificateRequestService.getRequestsByUser(user.uid);
        if (mounted) {
          setState(() {
            _requests = requests;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _requests = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error refreshing requests: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing requests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _manualRefresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _manualRefresh,
              child: _requests.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No requests yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Submit your first certificate request',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  _getStatusColor(request['status']),
                              child: Icon(
                                _getStatusIcon(request['status']),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              request['certName'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${request['id']}'),
                                Text('Type: ${request['certificateType']}'),
                                if (request['requestType'] == 'true_copy') ...[
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.purple.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      'TRUE COPY',
                                      style: TextStyle(
                                        color: Colors.purple[700],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                Text('Priority: ${request['priority']}'),
                                Text('Reason: ${request['reason']}'),
                                Text(
                                  'Requested: ${_formatDate(request['requestedAt'])}',
                                ),
                                if (request['fileUrl'] != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_file,
                                        size: 14,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'File attached',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(request['status'])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(request['status'])
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _getStatusText(request['status']),
                                style: TextStyle(
                                  color: _getStatusColor(request['status']),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            onTap: () {
                              _showRequestDetails(request);
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'in_progress':
        return Icons.work;
      default:
        return Icons.help;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';

    if (date is String) {
      // Handle ISO string format
      try {
        final dateTime = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      } catch (e) {
        return 'Invalid date';
      }
    } else if (date is DateTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } else if (date is Timestamp) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date.toDate());
    }
    return 'Unknown';
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request['certName']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request ID: ${request['id']}'),
              const SizedBox(height: 8),
              Text('Certificate Type: ${request['certificateType']}'),
              const SizedBox(height: 8),
              Text('Issuer: ${request['issuer'] ?? 'Not specified'}'),
              const SizedBox(height: 8),
              Text('Recipient: ${request['recipientName']}'),
              const SizedBox(height: 8),
              Text('Priority: ${request['priority']}'),
              const SizedBox(height: 8),
              Text('Status: ${_getStatusText(request['status'])}'),
              const SizedBox(height: 8),
              Text('Reason: ${request['reason']}'),
              if (request['description'] != null &&
                  request['description'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Description: ${request['description']}'),
              ],
              if (request['additionalInfo'] != null &&
                  request['additionalInfo'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Additional Info: ${request['additionalInfo']}'),
              ],
              const SizedBox(height: 8),
              Text('Requested: ${_formatDate(request['requestedAt'])}'),
              if (request['fileUrl'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.attach_file,
                              color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Attached File',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request['fileName'] ?? 'Unknown file',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (request['fileUrl'] != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _downloadFile(request['fileUrl'], request['fileName']);
              },
              icon: const Icon(Icons.download),
              label: const Text('Download File'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(String? fileUrl, String? fileName) async {
    if (fileUrl == null || fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file available for download'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
