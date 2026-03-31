/// Creative space image information
class CreativeSpaceImageDto {
  final int? id;
  final String url;
  final String? altText;
  final String? caption;
  final int? sortOrder;
  final bool isPrimary;

  const CreativeSpaceImageDto({
    this.id,
    required this.url,
    this.altText,
    this.caption,
    this.sortOrder,
    this.isPrimary = false,
  });

  /// Creates a [CreativeSpaceImageDto] from JSON
  factory CreativeSpaceImageDto.fromJson(Map<String, dynamic> json) {
    return CreativeSpaceImageDto(
      id: json['id'] as int?,
      url: json['url'] as String,
      altText: json['altText'] as String?,
      caption: json['caption'] as String?,
      sortOrder: json['sortOrder'] as int?,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  /// Converts [CreativeSpaceImageDto] to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'altText': altText,
      'caption': caption,
      'sortOrder': sortOrder,
      'isPrimary': isPrimary,
    };
  }

  /// Creates a copy with updated fields
  CreativeSpaceImageDto copyWith({
    int? id,
    String? url,
    String? altText,
    String? caption,
    int? sortOrder,
    bool? isPrimary,
  }) {
    return CreativeSpaceImageDto(
      id: id ?? this.id,
      url: url ?? this.url,
      altText: altText ?? this.altText,
      caption: caption ?? this.caption,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  String toString() {
    return 'CreativeSpaceImageDto(url: $url, isPrimary: $isPrimary, sortOrder: $sortOrder)';
  }
}
