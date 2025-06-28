class Certificate {
  final int? id;
  final String fileName;
  final String filePath;
  final String fileType;
  final double fileSize;
  final DateTime uploadDate;
  final String? description;
  final String? category;
  final String? firebaseUrl;

  Certificate({
    this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.uploadDate,
    this.description,
    this.category,
    this.firebaseUrl,
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
    String? firebaseUrl,
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
      firebaseUrl: firebaseUrl ?? this.firebaseUrl,
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
      'firebaseUrl': firebaseUrl,
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
      firebaseUrl: map['firebaseUrl'],
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
