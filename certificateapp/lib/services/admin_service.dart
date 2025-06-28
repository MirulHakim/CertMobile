import '../models/certificate.dart';
import '../models/user.dart';
import '../models/metadata_rule.dart';

class AdminService {
  // Singleton pattern
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  // Mock data - replace with actual database calls
  final List<Certificate> _certificates = [];
  final List<User> _users = [];
  final List<MetadataRule> _metadataRules = [];

  // CA Verification Methods
  Future<List<Certificate>> getPendingCertificates() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _certificates.where((cert) => 
      cert.status == CertificateStatus.pending || 
      cert.status == CertificateStatus.underReview
    ).toList();
  }

  Future<bool> approveCertificate(String certificateId, String approvedBy, String? notes) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _certificates.indexWhere((cert) => cert.id.toString() == certificateId);
    if (index != -1) {
      _certificates[index] = _certificates[index].copyWith(
        status: CertificateStatus.approved,
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
        verificationNotes: notes,
        isVerified: true,
      );
      return true;
    }
    return false;
  }

  Future<bool> rejectCertificate(String certificateId, String rejectedBy, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _certificates.indexWhere((cert) => cert.id.toString() == certificateId);
    if (index != -1) {
      _certificates[index] = _certificates[index].copyWith(
        status: CertificateStatus.rejected,
        approvedBy: rejectedBy,
        approvedAt: DateTime.now(),
        rejectionReason: reason,
      );
      return true;
    }
    return false;
  }

  Future<bool> markForReview(String certificateId, String reviewer) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _certificates.indexWhere((cert) => cert.id.toString() == certificateId);
    if (index != -1) {
      _certificates[index] = _certificates[index].copyWith(
        status: CertificateStatus.underReview,
        approvedBy: reviewer,
        approvedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  // User Management Methods
  Future<List<User>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _users;
  }

  Future<bool> createUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users.add(user);
    return true;
  }

  Future<bool> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      return true;
    }
    return false;
  }

  Future<bool> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users.removeWhere((user) => user.id == userId);
    return true;
  }

  Future<bool> toggleUserStatus(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: !_users[index].isActive);
      return true;
    }
    return false;
  }

  // Metadata Rules Methods
  Future<List<MetadataRule>> getAllMetadataRules() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _metadataRules;
  }

  Future<bool> createMetadataRule(MetadataRule rule) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _metadataRules.add(rule);
    return true;
  }

  Future<bool> updateMetadataRule(MetadataRule rule) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _metadataRules.indexWhere((r) => r.id == rule.id);
    if (index != -1) {
      _metadataRules[index] = rule;
      return true;
    }
    return false;
  }

  Future<bool> deleteMetadataRule(String ruleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _metadataRules.removeWhere((rule) => rule.id == ruleId);
    return true;
  }

  Future<bool> toggleMetadataRule(String ruleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _metadataRules.indexWhere((rule) => rule.id == ruleId);
    if (index != -1) {
      _metadataRules[index] = _metadataRules[index].copyWith(
        isActive: !_metadataRules[index].isActive,
      );
      return true;
    }
    return false;
  }

  // Validation Methods
  Future<Map<String, String>> validateCertificateMetadata(Map<String, dynamic> metadata) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final errors = <String, String>{};
    
    for (final rule in _metadataRules.where((r) => r.isActive)) {
      final value = metadata[rule.fieldName];
      if (!rule.validate(value)) {
        errors[rule.fieldName] = rule.getValidationMessage(value);
      }
    }
    
    return errors;
  }

  // Analytics Methods
  Future<Map<String, dynamic>> getSystemAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final totalCertificates = _certificates.length;
    final pendingCertificates = _certificates.where((c) => 
      c.status == CertificateStatus.pending).length;
    final approvedCertificates = _certificates.where((c) => 
      c.status == CertificateStatus.approved).length;
    final rejectedCertificates = _certificates.where((c) => 
      c.status == CertificateStatus.rejected).length;
    final activeUsers = _users.where((u) => u.isActive).length;
    final totalUsers = _users.length;
    final activeRules = _metadataRules.where((r) => r.isActive).length;
    final totalRules = _metadataRules.length;

    // Calculate monthly trends (mock data)
    final monthlyData = <String, int>{
      'Jan': 45,
      'Feb': 52,
      'Mar': 48,
      'Apr': 61,
      'May': 55,
      'Jun': 67,
    };

    return {
      'totalCertificates': totalCertificates,
      'pendingCertificates': pendingCertificates,
      'approvedCertificates': approvedCertificates,
      'rejectedCertificates': rejectedCertificates,
      'activeUsers': activeUsers,
      'totalUsers': totalUsers,
      'activeRules': activeRules,
      'totalRules': totalRules,
      'monthlyData': monthlyData,
      'approvalRate': totalCertificates > 0 
        ? ((approvedCertificates / totalCertificates) * 100).roundToDouble()
        : 0.0,
      'rejectionRate': totalCertificates > 0 
        ? ((rejectedCertificates / totalCertificates) * 100).roundToDouble()
        : 0.0,
    };
  }

  // Security Methods
  Future<List<Map<String, dynamic>>> getSecurityLogs() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return [
      {
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'action': 'Certificate Approved',
        'user': 'admin@example.com',
        'details': 'Flutter Developer Certificate approved',
        'severity': 'info',
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        'action': 'User Login',
        'user': 'john.doe@example.com',
        'details': 'Successful login from 192.168.1.100',
        'severity': 'info',
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'action': 'Failed Login Attempt',
        'user': 'unknown@example.com',
        'details': 'Failed login attempt from 203.0.113.1',
        'severity': 'warning',
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'action': 'Certificate Rejected',
        'user': 'admin@example.com',
        'details': 'Invalid certificate format detected',
        'severity': 'info',
      },
    ];
  }

  // Initialize with mock data
  void initializeMockData() {
    // Add some mock certificates
    _certificates.addAll([
      Certificate(
        id: 1,
        fileName: 'Flutter_Developer_Certificate.pdf',
        filePath: '/path/to/file1.pdf',
        fileType: 'pdf',
        fileSize: 1024 * 1024,
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Flutter Development Certification',
        category: 'Programming',
        status: CertificateStatus.pending,
        issuerName: 'Coursera',
        issuerId: 'CRS001',
        issueDate: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 335)),
        certificateNumber: 'FLT-2024-001',
        metadataHash: 'abc123def456',
        digitalSignature: 'sig123',
      ),
      Certificate(
        id: 2,
        fileName: 'AWS_Solutions_Architect.pdf',
        filePath: '/path/to/file2.pdf',
        fileType: 'pdf',
        fileSize: 2048 * 1024,
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        description: 'AWS Solutions Architect Associate',
        category: 'Cloud Computing',
        status: CertificateStatus.underReview,
        issuerName: 'Amazon Web Services',
        issuerId: 'AWS001',
        issueDate: DateTime.now().subtract(const Duration(days: 15)),
        expiryDate: DateTime.now().add(const Duration(days: 350)),
        certificateNumber: 'AWS-2024-002',
        metadataHash: 'def456ghi789',
        digitalSignature: 'sig456',
      ),
    ]);

    // Add some mock users
    _users.addAll([
      User(
        id: '1',
        email: 'admin@example.com',
        name: 'Admin User',
        role: UserRole.admin,
        organization: 'Example Corp',
        department: 'IT',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
      ),
      User(
        id: '2',
        email: 'ca.verifier@example.com',
        name: 'CA Verifier',
        role: UserRole.caVerifier,
        organization: 'Example Corp',
        department: 'Security',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
      ),
      User(
        id: '3',
        email: 'john.doe@example.com',
        name: 'John Doe',
        role: UserRole.user,
        organization: 'Example Corp',
        department: 'Engineering',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        lastLogin: DateTime.now().subtract(const Duration(minutes: 30)),
        isActive: true,
      ),
    ]);

    // Add some mock metadata rules
    _metadataRules.addAll([
      MetadataRule(
        id: '1',
        name: 'Certificate Number Format',
        description: 'Ensures certificate numbers follow the required format',
        fieldName: 'certificateNumber',
        fieldType: FieldType.text,
        ruleType: RuleType.format,
        pattern: r'^[A-Z]{3}-\d{4}-\d{3}$',
        errorMessage: 'Certificate number must follow format: XXX-YYYY-ZZZ',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'admin@example.com',
      ),
      MetadataRule(
        id: '2',
        name: 'Issuer Name Required',
        description: 'Issuer name is mandatory for all certificates',
        fieldName: 'issuerName',
        fieldType: FieldType.text,
        ruleType: RuleType.required,
        isRequired: true,
        errorMessage: 'Issuer name is required',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        createdBy: 'admin@example.com',
      ),
    ]);
  }
} 