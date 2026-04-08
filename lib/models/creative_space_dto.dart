import 'creative_space_image_dto.dart';

/// Creative space listing DTO
class CreativeSpaceDto {
  final int id;
  final String name;
  final String? shortDescription;
  final int? townId;
  final String? townName;
  final String? province;
  final int? categoryId;
  final String? categoryKey;
  final String? categoryName;
  final int? subCategoryId;
  final String? subCategoryKey;
  final String? subCategoryName;
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
  final String? primaryImageUrl;
  final bool allowsPurchase;
  final bool allowsShipping;
  final bool offersWorkshops;
  final String? priceRange;
  final String? bestVisitWindow;
  final String? operatingHoursSummary;
  final bool isOpenNow;
  final String? openNowText;
  final double? rating;
  final int totalReviews;
  final int viewCount;
  final bool isFeatured;
  final bool isVerified;
  final CreativeSpaceImageDto? thumbnailImage;

  const CreativeSpaceDto({
    required this.id,
    required this.name,
    this.shortDescription,
    this.townId,
    this.townName,
    this.province,
    this.categoryId,
    this.categoryKey,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryKey,
    this.subCategoryName,
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
    this.primaryImageUrl,
    this.allowsPurchase = false,
    this.allowsShipping = false,
    this.offersWorkshops = false,
    this.priceRange,
    this.bestVisitWindow,
    this.operatingHoursSummary,
    this.isOpenNow = false,
    this.openNowText,
    this.rating,
    required this.totalReviews,
    required this.viewCount,
    required this.isFeatured,
    required this.isVerified,
    this.thumbnailImage,
  });

  /// Creates a [CreativeSpaceDto] from JSON
  factory CreativeSpaceDto.fromJson(Map<String, dynamic> json) {
    return CreativeSpaceDto(
      id: json['id'] as int,
      name: json['name'] as String,
      shortDescription: json['shortDescription'] as String?,
      townId: json['townId'] as int?,
      townName: json['townName'] as String?,
      province: json['province'] as String?,
      categoryId: json['categoryId'] as int?,
      categoryKey: json['categoryKey'] as String?,
      categoryName: json['categoryName'] as String?,
      subCategoryId: json['subCategoryId'] as int?,
      subCategoryKey: json['subCategoryKey'] as String?,
      subCategoryName: json['subCategoryName'] as String?,
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
      primaryImageUrl: json['primaryImageUrl'] as String?,
      allowsPurchase: json['allowsPurchase'] as bool? ?? false,
      allowsShipping: json['allowsShipping'] as bool? ?? false,
      offersWorkshops: json['offersWorkshops'] as bool? ?? false,
      priceRange: json['priceRange'] as String?,
      bestVisitWindow: json['bestVisitWindow'] as String?,
      operatingHoursSummary: json['operatingHoursSummary'] as String?,
      isOpenNow: json['isOpenNow'] as bool? ?? false,
      openNowText: json['openNowText'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalReviews: json['totalReviews'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      thumbnailImage: json['thumbnailImage'] != null
          ? CreativeSpaceImageDto.fromJson(json['thumbnailImage'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts [CreativeSpaceDto] to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortDescription': shortDescription,
      'townId': townId,
      'townName': townName,
      'province': province,
      'categoryId': categoryId,
      'categoryKey': categoryKey,
      'categoryName': categoryName,
      'subCategoryId': subCategoryId,
      'subCategoryKey': subCategoryKey,
      'subCategoryName': subCategoryName,
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
      'primaryImageUrl': primaryImageUrl,
      'allowsPurchase': allowsPurchase,
      'allowsShipping': allowsShipping,
      'offersWorkshops': offersWorkshops,
      'priceRange': priceRange,
      'bestVisitWindow': bestVisitWindow,
      'operatingHoursSummary': operatingHoursSummary,
      'isOpenNow': isOpenNow,
      'openNowText': openNowText,
      'rating': rating,
      'totalReviews': totalReviews,
      'viewCount': viewCount,
      'isFeatured': isFeatured,
      'isVerified': isVerified,
      'thumbnailImage': thumbnailImage?.toJson(),
    };
  }

  /// Creates a copy with updated fields
  CreativeSpaceDto copyWith({
    int? id,
    String? name,
    String? shortDescription,
    int? townId,
    String? townName,
    String? province,
    int? categoryId,
    String? categoryKey,
    String? categoryName,
    int? subCategoryId,
    String? subCategoryKey,
    String? subCategoryName,
    String? story,
    String? visitType,
    String? craftType,
    String? materials,
    String? languages,
    String? physicalAddress,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? logoUrl,
    String? coverImageUrl,
    String? primaryImageUrl,
    bool? allowsPurchase,
    bool? allowsShipping,
    bool? offersWorkshops,
    String? priceRange,
    String? bestVisitWindow,
    String? operatingHoursSummary,
    bool? isOpenNow,
    String? openNowText,
    double? rating,
    int? totalReviews,
    int? viewCount,
    bool? isFeatured,
    bool? isVerified,
    CreativeSpaceImageDto? thumbnailImage,
  }) {
    return CreativeSpaceDto(
      id: id ?? this.id,
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      townId: townId ?? this.townId,
      townName: townName ?? this.townName,
      province: province ?? this.province,
      categoryId: categoryId ?? this.categoryId,
      categoryKey: categoryKey ?? this.categoryKey,
      categoryName: categoryName ?? this.categoryName,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      subCategoryKey: subCategoryKey ?? this.subCategoryKey,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      story: story ?? this.story,
      visitType: visitType ?? this.visitType,
      craftType: craftType ?? this.craftType,
      materials: materials ?? this.materials,
      languages: languages ?? this.languages,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      allowsPurchase: allowsPurchase ?? this.allowsPurchase,
      allowsShipping: allowsShipping ?? this.allowsShipping,
      offersWorkshops: offersWorkshops ?? this.offersWorkshops,
      priceRange: priceRange ?? this.priceRange,
      bestVisitWindow: bestVisitWindow ?? this.bestVisitWindow,
      operatingHoursSummary: operatingHoursSummary ?? this.operatingHoursSummary,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      openNowText: openNowText ?? this.openNowText,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      viewCount: viewCount ?? this.viewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      thumbnailImage: thumbnailImage ?? this.thumbnailImage,
    );
  }

  @override
  String toString() {
    return 'CreativeSpaceDto(id: $id, name: $name, categoryName: $categoryName, isFeatured: $isFeatured)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreativeSpaceDto &&
        other.id == id &&
        other.name == name &&
        other.categoryName == categoryName &&
        other.isFeatured == isFeatured &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        categoryName.hashCode ^
        isFeatured.hashCode ^
        isVerified.hashCode;
  }
}
