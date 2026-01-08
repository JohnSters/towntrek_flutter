import 'service_dto.dart';
import 'document_dto.dart';

class ServiceDetailDto extends ServiceDto {
  final String description;
  final String phoneNumber;
  final String? phoneNumber2;
  final String? emailAddress;
  final String? website;
  final bool availableWeekends;
  final bool availableAfterHours;
  final bool emergencyService;
  final DateTime createdAt;
  final List<ServiceImageDto> images;
  final List<ServiceOperatingHourDto> operatingHours;
  final List<DocumentDto> documents;

  const ServiceDetailDto({
    required super.id,
    required super.name,
    super.shortDescription,
    required super.townId,
    required super.townName,
    required super.province,
    super.categoryId,
    super.categoryName,
    super.subCategoryId,
    super.subCategoryName,
    super.serviceArea,
    super.serviceRadius,
    super.latitude,
    super.longitude,
    super.hourlyRate,
    super.priceRange,
    required super.offersQuotes,
    required super.mobileService,
    required super.onSiteService,
    super.logoUrl,
    super.coverImageUrl,
    super.rating,
    required super.totalReviews,
    required super.viewCount,
    required super.isFeatured,
    required super.isVerified,
    required this.description,
    required this.phoneNumber,
    this.phoneNumber2,
    this.emailAddress,
    this.website,
    required this.availableWeekends,
    required this.availableAfterHours,
    required this.emergencyService,
    required this.createdAt,
    this.images = const [],
    this.operatingHours = const [],
    this.documents = const [],
  });

  factory ServiceDetailDto.fromJson(Map<String, dynamic> json) {
    return ServiceDetailDto(
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
      description: json['description'] as String,
      phoneNumber: json['phoneNumber'] as String,
      phoneNumber2: json['phoneNumber2'] as String?,
      emailAddress: json['emailAddress'] as String?,
      website: json['website'] as String?,
      availableWeekends: json['availableWeekends'] as bool? ?? false,
      availableAfterHours: json['availableAfterHours'] as bool? ?? false,
      emergencyService: json['emergencyService'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ServiceImageDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      operatingHours: (json['operatingHours'] as List<dynamic>?)
              ?.map((e) => ServiceOperatingHourDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => DocumentDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ServiceImageDto {
  final int id;
  final String imageType;
  final String url;
  final String? thumbnailUrl;
  final String? altText;
  final int sortOrder;

  const ServiceImageDto({
    required this.id,
    required this.imageType,
    required this.url,
    this.thumbnailUrl,
    this.altText,
    required this.sortOrder,
  });

  factory ServiceImageDto.fromJson(Map<String, dynamic> json) {
    return ServiceImageDto(
      id: json['id'] as int,
      imageType: json['imageType'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      altText: json['altText'] as String?,
      sortOrder: json['sortOrder'] as int,
    );
  }
}

class ServiceOperatingHourDto {
  final int dayOfWeek;
  final String? startTime;
  final String? endTime;
  final bool isAvailable;
  final String? notes;

  const ServiceOperatingHourDto({
    required this.dayOfWeek,
    this.startTime,
    this.endTime,
    required this.isAvailable,
    this.notes,
  });

  factory ServiceOperatingHourDto.fromJson(Map<String, dynamic> json) {
    return ServiceOperatingHourDto(
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}

