/// Image information for a business
class BusinessImageDto {
  final int? id;
  final String url;
  final String? altText;
  final int? sortOrder;
  final bool isPrimary;

  const BusinessImageDto({
    this.id,
    required this.url,
    this.altText,
    this.sortOrder,
    required this.isPrimary,
  });

  /// Creates a BusinessImageDto from JSON
  factory BusinessImageDto.fromJson(Map<String, dynamic> json) {
    return BusinessImageDto(
      id: json['id'] as int?,
      url: json['url'] as String,
      altText: json['altText'] as String?,
      sortOrder: json['sortOrder'] as int?,
      isPrimary: json['isPrimary'] as bool,
    );
  }

  /// Converts BusinessImageDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'altText': altText,
      'sortOrder': sortOrder,
      'isPrimary': isPrimary,
    };
  }

  /// Creates a copy of BusinessImageDto with modified fields
  BusinessImageDto copyWith({
    int? id,
    String? url,
    String? altText,
    int? sortOrder,
    bool? isPrimary,
  }) {
    return BusinessImageDto(
      id: id ?? this.id,
      url: url ?? this.url,
      altText: altText ?? this.altText,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  String toString() {
    return 'BusinessImageDto(url: $url, isPrimary: $isPrimary, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessImageDto &&
        other.id == id &&
        other.url == url &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode {
    return id.hashCode ^ url.hashCode ^ isPrimary.hashCode;
  }
}
