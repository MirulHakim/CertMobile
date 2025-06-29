import 'dart:convert';

class CertificateRequestService {
  static final CertificateRequestService _instance =
      CertificateRequestService._internal();
  factory CertificateRequestService() => _instance;
  CertificateRequestService._internal();

  // Simple in-memory storage for requests (in a real app, this would be a database)
  static List<Map<String, dynamic>> _requests = [];

  // Get all requests
  List<Map<String, dynamic>> getAllRequests() {
    return List.from(_requests);
  }

  // Get requests by user ID
  List<Map<String, dynamic>> getRequestsByUser(String userId) {
    return _requests
        .where((request) => request['requestedBy'] == userId)
        .toList();
  }

  // Add a new request
  Future<void> addRequest(Map<String, dynamic> requestData) async {
    // Add a unique ID and timestamp
    final newRequest = {
      ...requestData,
      'id': 'REQ${DateTime.now().millisecondsSinceEpoch}',
      'requestedAt': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    _requests.add(newRequest);
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    final requestIndex = _requests.indexWhere((req) => req['id'] == requestId);
    if (requestIndex != -1) {
      _requests[requestIndex]['status'] = newStatus;
    }
  }

  // Clear all requests (for testing)
  void clearAllRequests() {
    _requests.clear();
  }
}
