import 'creative_space_dto.dart';
import 'creative_space_image_dto.dart';
import 'creative_space_operating_hour_dto.dart';
import 'document_dto.dart';
import 'review_dto.dart';

/// Detailed creative space DTO for individual item screens
class CreativeSpaceDetailDto {
  final int id;
  final String name;
  final String description;
  final int? townId;
  final String? townName;
  final String? province;
  final int? categoryId;
  final String? categoryName;
  final int? subCategoryId;
  final String? subCategoryName;
  final String? categoryKey;
  final String? subCategoryKey;
  final String? story;
  final String? visitType;
  final String? craftType;
  final String? materials;
  final String? languages;
  final String? physicalAddress;
  final String? city;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final String? coverImageUrl;
  final bool allowsPurchase;
  final bool allowsShipping;
  final String? priceRange;
  final String? bestVisitWindow;
  final String? contactPhone;
  final String? contactEmail;
  final String? contactWebsite;
  final bool offersWorkshops;
  final String? contactMessage;
  final bool isOpenNow;
  final String? openNowText;
  final bool hasFreeEntry;
  final double? rating;
  final int totalReviews;
  final int viewCount;
  final bool isFeatured;
  final bool isVerified;
  final bool? isCurrentlyOpen;
  final List<CreativeSpaceImageDto> images;
  final List<CreativeSpaceOperatingHourDto> operatingHours;
  final List<CreativeSpaceOperatingHourDto> specialOperatingHours;
  final List<ReviewDto> reviews;
  final List<DocumentDto> documents;
  final CreativeSpaceDto summary;

  const CreativeSpaceDetailDto({
    required this.id,
    required this.name,
    required this.description,
    this.townId,
    this.townName,
    this.province,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.categoryKey,
    this.subCategoryKey,
    this.story,
    this.visitType,
    this.craftType,
    this.materials,
    this.languages,
    this.physicalAddress,
    this.city,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.logoUrl,
    this.coverImageUrl,
    this.allowsPurchase = false,
    this.allowsShipping = false,
    this.priceRange,
    this.bestVisitWindow,
    this.contactPhone,
    this.contactEmail,
    this.contactWebsite,
    this.offersWorkshops = false,
    this.contactMessage,
    this.isOpenNow = false,
    this.openNowText,
    this.hasFreeEntry = false,
    this.rating,
    required this.totalReviews,
    required this.viewCount,
    required this.isFeatured,
    required this.isVerified,
    this.isCurrentlyOpen,
    this.images = const [],
    this.operatingHours = const [],
    this.specialOperatingHours = const [],
    this.reviews = const [],
    this.documents = const [],
    required this.summary,
  });

  /// Creates a [CreativeSpaceDetailDto] from JSON
  factory CreativeSpaceDetailDto.fromJson(Map<String, dynamic> json) {
    final summaryJson = Map<String, dynamic>.from(json);
    summaryJson.remove('description');
    summaryJson.remove('summary');
    summaryJson.remove('images');
    summaryJson.remove('operatingHours');
    summaryJson.remove('specialOperatingHours');
    summaryJson.remove('reviews');
    summaryJson.remove('documents');

    return CreativeSpaceDetailDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      townId: json['townId'] as int?,
      townName: json['townName'] as String?,
      province: json['province'] as String?,
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      subCategoryId: json['subCategoryId'] as int?,
      subCategoryName: json['subCategoryName'] as String?,
      categoryKey: json['categoryKey'] as String?,
      subCategoryKey: json['subCategoryKey'] as String?,
      story: json['story'] as String?,
      visitType: json['visitType'] as String?,
      craftType: json['craftType'] as String?,
      materials: json['materials'] as String?,
      languages: json['languages'] as String?,
      physicalAddress: json['physicalAddress'] as String?,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      allowsPurchase: json['allowsPurchase'] as bool? ?? false,
      allowsShipping: json['allowsShipping'] as bool? ?? false,
      priceRange: json['priceRange'] as String?,
      bestVisitWindow: json['bestVisitWindow'] as String?,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactWebsite: json['contactWebsite'] as String?,
      offersWorkshops: json['offersWorkshops'] as bool? ?? false,
      contactMessage: json['contactMessage'] as String?,
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      openNowText: json['openNowText'] as String?,
      hasFreeEntry: json['hasFreeEntry'] as bool? ?? false,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalReviews: json['totalReviews'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      isCurrentlyOpen: json['isCurrentlyOpen'] as bool?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => CreativeSpaceImageDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      operatingHours: (json['operatingHours'] as List<dynamic>?)
              ?.map((e) => CreativeSpaceOperatingHourDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      specialOperatingHours: (json['specialOperatingHours'] as List<dynamic>?)
              ?.map((e) => CreativeSpaceOperatingHourDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => DocumentDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      summary: CreativeSpaceDto.fromJson(summaryJson),
    );
  }

  /// Converts [CreativeSpaceDetailDto] to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'townId': townId,
      'townName': townName,
      'province': province,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subCategoryId': subCategoryId,
      'subCategoryName': subCategoryName,
      'categoryKey': categoryKey,
      'subCategoryKey': subCategoryKey,
      'story': story,
      'visitType': visitType,
      'craftType': craftType,
      'materials': materials,
      'languages': languages,
      'physicalAddress': physicalAddress,
      'city': city,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'allowsPurchase': allowsPurchase,
      'allowsShipping': allowsShipping,
      'priceRange': priceRange,
      'bestVisitWindow': bestVisitWindow,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'contactWebsite': contactWebsite,
      'offersWorkshops': offersWorkshops,
      'contactMessage': contactMessage,
      'isOpenNow': isOpenNow,
      'openNowText': openNowText,
      'hasFreeEntry': hasFreeEntry,
      'rating': rating,
      'totalReviews': totalReviews,
      'viewCount': viewCount,
      'isFeatured': isFeatured,
      'isVerified': isVerified,
      'isCurrentlyOpen': isCurrentlyOpen,
      'images': images.map((e) => e.toJson()).toList(),
      'operatingHours': operatingHours.map((e) => e.toJson()).toList(),
      'specialOperatingHours': specialOperatingHours.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'documents': documents.map((e) => e.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }
}
