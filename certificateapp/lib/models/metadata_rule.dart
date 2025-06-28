enum RuleType {
  required,
  format,
  range,
  custom
}

enum FieldType {
  text,
  number,
  date,
  email,
  url,
  file
}

class MetadataRule {
  final String id;
  final String name;
  final String description;
  final String fieldName;
  final FieldType fieldType;
  final RuleType ruleType;
  final bool isRequired;
  final String? pattern;
  final dynamic minValue;
  final dynamic maxValue;
  final String? customValidation;
  final String? errorMessage;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  MetadataRule({
    required this.id,
    required this.name,
    required this.description,
    required this.fieldName,
    required this.fieldType,
    required this.ruleType,
    this.isRequired = false,
    this.pattern,
    this.minValue,
    this.maxValue,
    this.customValidation,
    this.errorMessage,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  MetadataRule copyWith({
    String? id,
    String? name,
    String? description,
    String? fieldName,
    FieldType? fieldType,
    RuleType? ruleType,
    bool? isRequired,
    String? pattern,
    dynamic minValue,
    dynamic maxValue,
    String? customValidation,
    String? errorMessage,
    bool? isActive,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return MetadataRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      ruleType: ruleType ?? this.ruleType,
      isRequired: isRequired ?? this.isRequired,
      pattern: pattern ?? this.pattern,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      customValidation: customValidation ?? this.customValidation,
      errorMessage: errorMessage ?? this.errorMessage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'fieldName': fieldName,
      'fieldType': fieldType.name,
      'ruleType': ruleType.name,
      'isRequired': isRequired,
      'pattern': pattern,
      'minValue': minValue,
      'maxValue': maxValue,
      'customValidation': customValidation,
      'errorMessage': errorMessage,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory MetadataRule.fromMap(Map<String, dynamic> map) {
    return MetadataRule(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      fieldName: map['fieldName'],
      fieldType: FieldType.values.firstWhere(
        (e) => e.name == map['fieldType'],
        orElse: () => FieldType.text,
      ),
      ruleType: RuleType.values.firstWhere(
        (e) => e.name == map['ruleType'],
        orElse: () => RuleType.required,
      ),
      isRequired: map['isRequired'] ?? false,
      pattern: map['pattern'],
      minValue: map['minValue'],
      maxValue: map['maxValue'],
      customValidation: map['customValidation'],
      errorMessage: map['errorMessage'],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
    );
  }

  bool validate(dynamic value) {
    // Required field validation
    if (isRequired && (value == null || value.toString().trim().isEmpty)) {
      return false;
    }

    // Skip other validations if value is null/empty and not required
    if (value == null || value.toString().trim().isEmpty) {
      return true;
    }

    switch (ruleType) {
      case RuleType.required:
        return value != null && value.toString().trim().isNotEmpty;
      
      case RuleType.format:
        if (pattern != null) {
          final regex = RegExp(pattern!);
          return regex.hasMatch(value.toString());
        }
        return true;
      
      case RuleType.range:
        if (fieldType == FieldType.number) {
          final numValue = double.tryParse(value.toString());
          if (numValue == null) return false;
          
          if (minValue != null && numValue < minValue) return false;
          if (maxValue != null && numValue > maxValue) return false;
        } else if (fieldType == FieldType.date) {
          final dateValue = DateTime.tryParse(value.toString());
          if (dateValue == null) return false;
          
          if (minValue != null && dateValue.isBefore(DateTime.parse(minValue.toString()))) return false;
          if (maxValue != null && dateValue.isAfter(DateTime.parse(maxValue.toString()))) return false;
        }
        return true;
      
      case RuleType.custom:
        // Custom validation logic would be implemented here
        return true;
    }
  }

  String getValidationMessage(dynamic value) {
    if (!validate(value)) {
      return errorMessage ?? 'Validation failed for $fieldName';
    }
    return '';
  }
} 