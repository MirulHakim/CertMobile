import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file to Firebase Storage
  Future<String?> uploadFile(File file, String fileName) async {
    try {
      // Create a unique file name to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(fileName);
      final uniqueFileName = 'certificates/$timestamp$extension';

      // Create a reference to the file location in Firebase Storage
      final storageRef = _storage.ref().child(uniqueFileName);

      // Upload the file
      final uploadTask = storageRef.putFile(file);

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Delete a file from Firebase Storage
  Future<bool> deleteFile(String downloadUrl) async {
    try {
      // Create a reference from the download URL
      final ref = _storage.refFromURL(downloadUrl);

      // Delete the file
      await ref.delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file metadata from Firebase Storage
  Future<Map<String, dynamic>?> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final metadata = await ref.getMetadata();

      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
      };
    } catch (e) {
      return null;
    }
  }
}
