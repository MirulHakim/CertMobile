import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/certificate_request_service.dart';

class CertificateRequestsPage extends StatefulWidget {
  const CertificateRequestsPage({super.key});

  @override
  State<CertificateRequestsPage> createState() =>
      _CertificateRequestsPageState();
}

class _CertificateRequestsPageState extends State<CertificateRequestsPage> {
  final AuthService _authService = AuthService();
  final CertificateRequestService _certificateRequestService =
      CertificateRequestService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _requests = [];
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      _requests = await _certificateRequestService.getAllRequests();
    } catch (e) {
      print('Error loading requests: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredRequests {
    if (_filterStatus == 'all') {
      return _requests;
    }
    return _requests
        .where((request) => request['status'] == _filterStatus)
        .toList();
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.grey;
      case 'medium':
        return Colors.blue;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _certificateRequestService.updateRequestStatus(
          requestId, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${newStatus.toLowerCase()} successfully'),
            backgroundColor:
                newStatus == 'approved' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating request: $e'),
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
        title: const Text('Certificate Requests'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Filter by Status: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _filterStatus,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(
                              value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(
                              value: 'approved', child: Text('Approved')),
                          DropdownMenuItem(
                              value: 'rejected', child: Text('Rejected')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value!;
                          });
                        },
                      ),
                      const Spacer(),
                      Text(
                        '${_filteredRequests.length} requests',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Requests List
                Expanded(
                  child: _filteredRequests.isEmpty
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
                                'No requests found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = _filteredRequests[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${request['id']}'),
                                    Text('Type: ${request['certificateType']}'),
                                    Text(
                                        'Recipient: ${request['recipientName']}'),
                                    Text('Issuer: ${request['issuer']}'),
                                    if (request['requestType'] ==
                                        'true_copy') ...[
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color:
                                                Colors.purple.withOpacity(0.3),
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(
                                                    request['priority'])
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _getPriorityColor(
                                                      request['priority'])
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            request['priority'],
                                            style: TextStyle(
                                              color: _getPriorityColor(
                                                  request['priority']),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                    request['status'])
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _getStatusColor(
                                                      request['status'])
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            _getStatusText(request['status']),
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                  request['status']),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: request['hasAttachment']
                                    ? const Icon(Icons.attach_file,
                                        color: Colors.blue)
                                    : null,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reason: ${request['reason']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Requested: ${_formatDate(request['requestedAt'])}',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 16),
                                        if (request['status'] == 'pending') ...[
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () =>
                                                      _updateRequestStatus(
                                                    request['id'],
                                                    'approved',
                                                  ),
                                                  icon: const Icon(Icons.check),
                                                  label: const Text('Approve'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () =>
                                                      _updateRequestStatus(
                                                    request['id'],
                                                    'rejected',
                                                  ),
                                                  icon: const Icon(Icons.close),
                                                  label: const Text('Reject'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ] else ...[
                                          Text(
                                            'Status: ${_getStatusText(request['status'])}',
                                            style: TextStyle(
                                              color: _getStatusColor(
                                                  request['status']),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
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
    if (date is String) {
      // Handle ISO string format
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Unknown';
  }
}
