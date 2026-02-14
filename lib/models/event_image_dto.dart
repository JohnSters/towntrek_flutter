/// Image information for an event
class EventImageDto {
  final int id;
  final String url;
  final String? altText;
  final int sortOrder;
  final String imageType;

  const EventImageDto({
    required this.id,
    required this.url,
    this.altText,
    required this.sortOrder,
    required this.imageType,
  });

  /// Creates an EventImageDto from JSON
  factory EventImageDto.fromJson(Map<String, dynamic> json) {
    return EventImageDto(
      id: json['id'] as int,
      url: json['url'] as String,
      altText: json['altText'] as String?,
      sortOrder: json['sortOrder'] as int,
      imageType: json['imageType'] as String,
    );
  }

  /// Converts EventImageDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'altText': altText,
      'sortOrder': sortOrder,
      'imageType': imageType,
    };
  }

  /// Creates a copy of EventImageDto with modified fields
  EventImageDto copyWith({
    int? id,
    String? url,
    String? altText,
    int? sortOrder,
    String? imageType,
  }) {
    return EventImageDto(
      id: id ?? this.id,
      url: url ?? this.url,
      altText: altText ?? this.altText,
      sortOrder: sortOrder ?? this.sortOrder,
      imageType: imageType ?? this.imageType,
    );
  }

  /// Check if this is a primary/featured image
  bool get isPrimary => imageType == 'Logo' || sortOrder == 0;

  @override
  String toString() {
    return 'EventImageDto(url: $url, sortOrder: $sortOrder, imageType: $imageType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventImageDto &&
        other.id == id &&
        other.url == url &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return id.hashCode ^ url.hashCode ^ sortOrder.hashCode;
  }
}
