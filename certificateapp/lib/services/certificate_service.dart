import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/certificate.dart';
import 'database_helper.dart';

class CertificateService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<String> _getCertificateDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final certDir = Directory('${appDir.path}/certificates');
    if (!await certDir.exists()) {
      await certDir.create(recursive: true);
    }
    return certDir.path;
  }

  Future<Certificate?> addCertificate() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = await file.length();
        final fileExtension = path.extension(fileName).toLowerCase();
        
        // Determine file type
        String fileType;
        switch (fileExtension) {
          case '.pdf':
            fileType = 'PDF';
            break;
          case '.jpg':
          case '.jpeg':
          case '.png':
            fileType = 'Image';
            break;
          case '.doc':
          case '.docx':
            fileType = 'Document';
            break;
          default:
            fileType = 'Other';
        }

        // Copy file to app directory
        final certDir = await _getCertificateDirectory();
        final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
        final newFilePath = path.join(certDir, uniqueFileName);
        await file.copy(newFilePath);

        // Create certificate record
        final certificate = Certificate(
          fileName: fileName,
          filePath: newFilePath,
          fileType: fileType,
          fileSize: fileSize.toDouble(),
          uploadDate: DateTime.now(),
          description: 'Certificate uploaded on ${DateTime.now().toString().split(' ')[0]}',
          category: 'General',
        );

        // Save to database
        final id = await _databaseHelper.insertCertificate(certificate);
        return certificate.copyWith(id: id);
      }
      return null;
    } catch (e) {
      // Error adding certificate
      return null;
    }
  }

  Future<List<Certificate>> getAllCertificates() async {
    return await _databaseHelper.getAllCertificates();
  }

  Future<Certificate?> getCertificate(int id) async {
    return await _databaseHelper.getCertificate(id);
  }

  Future<bool> deleteCertificate(int id) async {
    try {
      final certificate = await _databaseHelper.getCertificate(id);
      if (certificate != null) {
        // Delete file from storage
        final file = File(certificate.filePath);
        if (await file.exists()) {
          await file.delete();
        }
        
        // Delete from database
        await _databaseHelper.deleteCertificate(id);
        return true;
      }
      return false;
    } catch (e) {
      // Error deleting certificate
      return false;
    }
  }

  Future<bool> updateCertificate(Certificate certificate) async {
    try {
      await _databaseHelper.updateCertificate(certificate);
      return true;
    } catch (e) {
      // Error updating certificate
      return false;
    }
  }

  Future<List<Certificate>> searchCertificates(String query) async {
    return await _databaseHelper.searchCertificates(query);
  }

  Future<List<Certificate>> getCertificatesByCategory(String category) async {
    return await _databaseHelper.getCertificatesByCategory(category);
  }

  Future<File?> getCertificateFile(int id) async {
    try {
      final certificate = await _databaseHelper.getCertificate(id);
      if (certificate != null) {
        final file = File(certificate.filePath);
        if (await file.exists()) {
          return file;
        }
      }
      return null;
    } catch (e) {
      // Error getting certificate file
      return null;
    }
  }
} 