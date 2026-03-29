import 'property_listing_image_dto.dart';

/// Full property listing payload from `GET api/properties/{id}`
class PropertyListingDetailDto {
  final int id;
  final String ownerName;
  final String address;
  final String telephoneNumber;
  final String townName;
  /// Matches server enum: 0 = ForRent, 1 = ForSale
  final int listingType;
  final double price;
  final String? shortDescription;
  final String? description;
  final double? latitude;
  final double? longitude;
  final int viewCount;
  final bool isFeatured;
  final List<PropertyListingImageDto> images;

  const PropertyListingDetailDto({
    required this.id,
    required this.ownerName,
    required this.address,
    required this.telephoneNumber,
    required this.townName,
    required this.listingType,
    required this.price,
    this.shortDescription,
    this.description,
    this.latitude,
    this.longitude,
    required this.viewCount,
    required this.isFeatured,
    required this.images,
  });

  factory PropertyListingDetailDto.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    return PropertyListingDetailDto(
      id: json['id'] as int,
      ownerName: json['ownerName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      telephoneNumber: json['telephoneNumber'] as String? ?? '',
      townName: json['townName'] as String? ?? '',
      listingType: json['listingType'] as int? ?? 0,
      price: _readPrice(json['price']),
      shortDescription: json['shortDescription'] as String?,
      description: json['description'] as String?,
      latitude: _readDouble(json['latitude']),
      longitude: _readDouble(json['longitude']),
      viewCount: json['viewCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      images: rawImages
          .map((e) => PropertyListingImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _readPrice(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
