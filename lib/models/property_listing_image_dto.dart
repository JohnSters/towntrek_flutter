/// Image on a property listing detail (public API)
class PropertyListingImageDto {
  final String imageUrl;
  final String? thumbnailUrl;
  final int displayOrder;

  const PropertyListingImageDto({
    required this.imageUrl,
    this.thumbnailUrl,
    required this.displayOrder,
  });

  factory PropertyListingImageDto.fromJson(Map<String, dynamic> json) {
    return PropertyListingImageDto(
      imageUrl: json['imageUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }
}
