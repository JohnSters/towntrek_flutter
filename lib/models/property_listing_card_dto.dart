/// Card summary for a property listing (public API)
class PropertyListingCardDto {
  final int id;
  final String ownerName;
  final String address;
  final String townName;
  final String province;
  /// Matches server enum: 0 = ForRent, 1 = ForSale
  final int listingType;
  final double price;
  final String? primaryImageUrl;
  final bool isFeatured;
  final int viewCount;
  final String? summary;
  final String telephoneNumber;

  const PropertyListingCardDto({
    required this.id,
    required this.ownerName,
    required this.address,
    required this.townName,
    required this.province,
    required this.listingType,
    required this.price,
    this.primaryImageUrl,
    required this.isFeatured,
    required this.viewCount,
    this.summary,
    required this.telephoneNumber,
  });

  factory PropertyListingCardDto.fromJson(Map<String, dynamic> json) {
    return PropertyListingCardDto(
      id: json['id'] as int,
      ownerName: json['ownerName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      townName: json['townName'] as String? ?? '',
      province: json['province'] as String? ?? '',
      listingType: json['listingType'] as int? ?? 0,
      price: _readPrice(json['price']),
      primaryImageUrl: json['primaryImageUrl'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      summary: json['summary'] as String?,
      telephoneNumber: json['telephoneNumber'] as String? ?? '',
    );
  }

  static double _readPrice(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
