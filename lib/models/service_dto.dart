/// Data transfer object for service information in listings
class ServiceDto {
  final int id;
  final String name;
  final String? shortDescription;
  final int townId;
  final String townName;
  final String province;
  final int? categoryId;
  final String? categoryName;
  final int? subCategoryId;
  final String? subCategoryName;
  final String? serviceArea;
  final double? serviceRadius;
  final double? latitude;
  final double? longitude;
  final double? hourlyRate;
  final String? priceRange;
  final bool offersQuotes;
  final bool mobileService;
  final bool onSiteService;
  final String? logoUrl;
  final String? coverImageUrl;
  final double? rating;
  final int totalReviews;
  final int viewCount;
  final bool isFeatured;
  final bool isVerified;

  const ServiceDto({
    required this.id,
    required this.name,
    this.shortDescription,
    required this.townId,
    required this.townName,
    required this.province,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.serviceArea,
    this.serviceRadius,
    this.latitude,
    this.longitude,
    this.hourlyRate,
    this.priceRange,
    required this.offersQuotes,
    required this.mobileService,
    required this.onSiteService,
    this.logoUrl,
    this.coverImageUrl,
    this.rating,
    required this.totalReviews,
    required this.viewCount,
    required this.isFeatured,
    required this.isVerified,
  });

  factory ServiceDto.fromJson(Map<String, dynamic> json) {
    return ServiceDto(
      id: json['id'] as int,
      name: json['name'] as String,
      shortDescription: json['shortDescription'] as String?,
      townId: json['townId'] as int,
      townName: json['townName'] as String,
      province: json['province'] as String,
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      subCategoryId: json['subCategoryId'] as int?,
      subCategoryName: json['subCategoryName'] as String?,
      serviceArea: json['serviceArea'] as String?,
      serviceRadius: json['serviceRadius'] != null ? (json['serviceRadius'] as num).toDouble() : null,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      hourlyRate: json['hourlyRate'] != null ? (json['hourlyRate'] as num).toDouble() : null,
      priceRange: json['priceRange'] as String?,
      offersQuotes: json['offersQuotes'] as bool? ?? false,
      mobileService: json['mobileService'] as bool? ?? false,
      onSiteService: json['onSiteService'] as bool? ?? false,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalReviews: json['totalReviews'] as int,
      viewCount: json['viewCount'] as int,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}

