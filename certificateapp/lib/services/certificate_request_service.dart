import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class CertificateRequestService {
  static final CertificateRequestService _instance =
      CertificateRequestService._internal();
  factory CertificateRequestService() => _instance;
  CertificateRequestService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Add a new certificate request with file upload
  Future<String?> addRequest(Map<String, dynamic> requestData,
      {File? file}) async {
    try {
      String? fileUrl;
      String? fileName;

      // Upload file to Firebase Storage if provided
      if (file != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = path.extension(file.path);
        final originalName = path.basename(file.path);
        fileName = originalName;

        // Create unique file name for storage
        final uniqueFileName = 'certificate_requests/$timestamp$extension';
        final storageRef = _storage.ref().child(uniqueFileName);

        // Upload file
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask;

        // Get download URL
        fileUrl = await snapshot.ref.getDownloadURL();
      }

      // Prepare request data for Firestore
      final newRequest = {
        ...requestData,
        'id': 'REQ${DateTime.now().millisecondsSinceEpoch}',
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'fileUrl': fileUrl,
        'fileName': fileName,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      final docRef =
          await _firestore.collection('certificate_requests').add(newRequest);

      return docRef.id;
    } catch (e) {
      print('Error adding certificate request: $e');
      return null;
    }
  }

  /// Get all certificate requests
  Future<List<Map<String, dynamic>>> getAllRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection('certificate_requests')
          .orderBy('requestedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting all requests: $e');
      return [];
    }
  }

  /// Get requests by user ID
  Future<List<Map<String, dynamic>>> getRequestsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('certificate_requests')
          .where('requestedBy', isEqualTo: userId)
          .orderBy('requestedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting user requests: $e');
      return [];
    }
  }

  /// Get requests by status
  Future<List<Map<String, dynamic>>> getRequestsByStatus(String status) async {
    try {
      final querySnapshot = await _firestore
          .collection('certificate_requests')
          .where('status', isEqualTo: status)
          .orderBy('requestedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting requests by status: $e');
      return [];
    }
  }

  /// Update request status
  Future<bool> updateRequestStatus(String requestId, String newStatus,
      {String? adminNotes}) async {
    try {
      await _firestore
          .collection('certificate_requests')
          .doc(requestId)
          .update({
        'status': newStatus,
        'adminNotes': adminNotes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating request status: $e');
      return false;
    }
  }

  /// Get a single request by ID
  Future<Map<String, dynamic>?> getRequestById(String requestId) async {
    try {
      final doc = await _firestore
          .collection('certificate_requests')
          .doc(requestId)
          .get();

      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data()!,
        };
      }
      return null;
    } catch (e) {
      print('Error getting request by ID: $e');
      return null;
    }
  }

  /// Delete a request and its associated file
  Future<bool> deleteRequest(String requestId) async {
    try {
      // Get the request to find the file URL
      final request = await getRequestById(requestId);
      if (request != null && request['fileUrl'] != null) {
        // Delete file from Firebase Storage
        try {
          final ref = _storage.refFromURL(request['fileUrl']);
          await ref.delete();
        } catch (e) {
          print('Error deleting file from storage: $e');
          // Continue with document deletion even if file deletion fails
        }
      }

      // Delete document from Firestore
      await _firestore
          .collection('certificate_requests')
          .doc(requestId)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting request: $e');
      return false;
    }
  }

  /// Stream of requests for real-time updates
  Stream<List<Map<String, dynamic>>> getRequestsStream() {
    return _firestore
        .collection('certificate_requests')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Stream of user requests for real-time updates
  Stream<List<Map<String, dynamic>>> getUserRequestsStream(String userId) {
    return _firestore
        .collection('certificate_requests')
        .where('requestedBy', isEqualTo: userId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }
}
