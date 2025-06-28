import 'certificate.dart';

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? organization;
  final String? department;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final List<String> permissions;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.organization,
    this.department,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.permissions = const [],
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? organization,
    String? department,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    List<String>? permissions,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      organization: organization ?? this.organization,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'organization': organization,
      'department': department,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'permissions': permissions,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
      organization: map['organization'],
      department: map['department'],
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
      isActive: map['isActive'] ?? true,
      permissions: List<String>.from(map['permissions'] ?? []),
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isCAVerifier => role == UserRole.caVerifier;
  bool get canApproveCertificates => isAdmin || isCAVerifier;
  bool get canViewAllCertificates => isAdmin || isCAVerifier;
  bool get canManageUsers => isAdmin;
  bool get canViewAnalytics => isAdmin || isCAVerifier;
} 