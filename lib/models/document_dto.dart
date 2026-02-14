class DocumentDto {
  final int id;
  final String documentType;
  final String originalFileName;
  final String? description;
  final int fileSize;
  final String contentType;
  final String downloadUrl;

  const DocumentDto({
    required this.id,
    required this.documentType,
    required this.originalFileName,
    this.description,
    required this.fileSize,
    required this.contentType,
    required this.downloadUrl,
  });

  factory DocumentDto.fromJson(Map<String, dynamic> json) {
    return DocumentDto(
      id: json['id'] as int,
      documentType: json['documentType'] as String? ?? '',
      originalFileName: json['originalFileName'] as String? ?? '',
      description: json['description'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      contentType: json['contentType'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentType': documentType,
      'originalFileName': originalFileName,
      'description': description,
      'fileSize': fileSize,
      'contentType': contentType,
      'downloadUrl': downloadUrl,
    };
  }
}

