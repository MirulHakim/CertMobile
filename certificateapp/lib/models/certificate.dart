import 'package:flutter/material.dart';

enum CertificateStatus {
  pending,
  approved,
  rejected,
  underReview,
  expired,
  revoked
}

enum UserRole {
  user,
  admin,
  caVerifier
}

// Extension to add helper methods to CertificateStatus enum
extension CertificateStatusExtension on CertificateStatus {
  String get statusDisplay {
    switch (this) {
      case CertificateStatus.pending:
        return 'Pending';
      case CertificateStatus.approved:
        return 'Approved';
      case CertificateStatus.rejected:
        return 'Rejected';
      case CertificateStatus.underReview:
        return 'Under Review';
      case CertificateStatus.expired:
        return 'Expired';
      case CertificateStatus.revoked:
        return 'Revoked';
    }
  }

  Color get statusColor {
    switch (this) {
      case CertificateStatus.pending:
        return Colors.orange;
      case CertificateStatus.approved:
        return Colors.green;
      case CertificateStatus.rejected:
        return Colors.red;
      case CertificateStatus.underReview:
        return Colors.blue;
      case CertificateStatus.expired:
        return Colors.grey;
      case CertificateStatus.revoked:
        return Colors.red[700]!;
    }
  }
}

class Certificate {
  final int? id;
  final String fileName;
  final String filePath;
  final String fileType;
  final double fileSize;
  final DateTime uploadDate;
  final String? description;
  final String? category;
  final CertificateStatus status;
  final String? issuerName;
  final String? issuerId;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? certificateNumber;
  final String? metadataHash;
  final String? digitalSignature;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final Map<String, dynamic>? metadata;
  final bool isVerified;
  final String? verificationNotes;

  Certificate({
    this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.uploadDate,
    this.description,
    this.category,
    this.status = CertificateStatus.pending,
    this.issuerName,
    this.issuerId,
    this.issueDate,
    this.expiryDate,
    this.certificateNumber,
    this.metadataHash,
    this.digitalSignature,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.metadata,
    this.isVerified = false,
    this.verificationNotes,
  });

  Certificate copyWith({
    int? id,
    String? fileName,
    String? filePath,
    String? fileType,
    double? fileSize,
    DateTime? uploadDate,
    String? description,
    String? category,
    CertificateStatus? status,
    String? issuerName,
    String? issuerId,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? certificateNumber,
    String? metadataHash,
    String? digitalSignature,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    Map<String, dynamic>? metadata,
    bool? isVerified,
    String? verificationNotes,
  }) {
    return Certificate(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadDate: uploadDate ?? this.uploadDate,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      issuerName: issuerName ?? this.issuerName,
      issuerId: issuerId ?? this.issuerId,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      metadataHash: metadataHash ?? this.metadataHash,
      digitalSignature: digitalSignature ?? this.digitalSignature,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      metadata: metadata ?? this.metadata,
      isVerified: isVerified ?? this.isVerified,
      verificationNotes: verificationNotes ?? this.verificationNotes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadDate': uploadDate.toIso8601String(),
      'description': description,
      'category': category,
      'status': status.name,
      'issuerName': issuerName,
      'issuerId': issuerId,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'certificateNumber': certificateNumber,
      'metadataHash': metadataHash,
      'digitalSignature': digitalSignature,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'metadata': metadata,
      'isVerified': isVerified,
      'verificationNotes': verificationNotes,
    };
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'],
      fileName: map['fileName'],
      filePath: map['filePath'],
      fileType: map['fileType'],
      fileSize: map['fileSize'],
      uploadDate: DateTime.parse(map['uploadDate']),
      description: map['description'],
      category: map['category'],
      status: CertificateStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CertificateStatus.pending,
      ),
      issuerName: map['issuerName'],
      issuerId: map['issuerId'],
      issueDate: map['issueDate'] != null ? DateTime.parse(map['issueDate']) : null,
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      certificateNumber: map['certificateNumber'],
      metadataHash: map['metadataHash'],
      digitalSignature: map['digitalSignature'],
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
      rejectionReason: map['rejectionReason'],
      metadata: map['metadata'],
      isVerified: map['isVerified'] ?? false,
      verificationNotes: map['verificationNotes'],
    );
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize.toStringAsFixed(1)} B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
} 