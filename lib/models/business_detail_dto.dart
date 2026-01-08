import 'business_image_dto.dart';
import 'business_service_dto.dart';
import 'document_dto.dart';
import 'operating_hour_dto.dart';
import 'review_dto.dart';
import 'special_operating_hour_dto.dart';

/// Detailed business information for individual business pages
class BusinessDetailDto {
  final int id;
  final String name;
  final String description;
  final String category;
  final String? subCategory;
  final String? phoneNumber;
  final String? emailAddress;
  final String? website;
  final String? whatsApp;
  final String? facebook;
  final String? instagram;
  final String? physicalAddress;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final String? coverImageUrl;
  final double? rating;
  final int totalReviews;
  final int viewCount;
  final bool isFeatured;
  final bool isVerified;

  /// Optional server-calculated status (preferred for production consistency)
  final bool? isOpenNow;
  final String? openNowText;

  final List<OperatingHourDto> operatingHours;
  final List<SpecialOperatingHourDto> specialOperatingHours;
  final List<BusinessServiceDto> services;
  final List<BusinessImageDto> images;
  final List<ReviewDto> reviews;
  final List<DocumentDto> documents;

  const BusinessDetailDto({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.subCategory,
    this.phoneNumber,
    this.emailAddress,
    this.website,
    this.whatsApp,
    this.facebook,
    this.instagram,
    this.physicalAddress,
    this.latitude,
    this.longitude,
    this.logoUrl,
    this.coverImageUrl,
    this.rating,
    required this.totalReviews,
    required this.viewCount,
    required this.isFeatured,
    required this.isVerified,
    this.isOpenNow,
    this.openNowText,
    required this.operatingHours,
    required this.specialOperatingHours,
    required this.services,
    required this.images,
    required this.reviews,
    this.documents = const [],
  });

  /// Creates a BusinessDetailDto from JSON
  factory BusinessDetailDto.fromJson(Map<String, dynamic> json) {
    return BusinessDetailDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      emailAddress: json['emailAddress'] as String?,
      website: json['website'] as String?,
      whatsApp: json['whatsApp'] as String?,
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      physicalAddress: json['physicalAddress'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalReviews: json['totalReviews'] as int,
      viewCount: json['viewCount'] as int,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      isOpenNow: json['isOpenNow'] as bool?,
      openNowText: json['openNowText'] as String?,
      operatingHours: (json['operatingHours'] as List<dynamic>?)
          ?.map((e) => OperatingHourDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      specialOperatingHours: (json['specialOperatingHours'] as List<dynamic>?)
          ?.map((e) => SpecialOperatingHourDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => BusinessServiceDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => BusinessImageDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => ReviewDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => DocumentDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converts BusinessDetailDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'website': website,
      'whatsApp': whatsApp,
      'facebook': facebook,
      'instagram': instagram,
      'physicalAddress': physicalAddress,
      'latitude': latitude,
      'longitude': longitude,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'viewCount': viewCount,
      'isFeatured': isFeatured,
      'isVerified': isVerified,
      'isOpenNow': isOpenNow,
      'openNowText': openNowText,
      'operatingHours': operatingHours.map((e) => e.toJson()).toList(),
      'specialOperatingHours': specialOperatingHours.map((e) => e.toJson()).toList(),
      'services': services.map((e) => e.toJson()).toList(),
      'images': images.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'documents': documents.map((e) => e.toJson()).toList(),
    };
  }

  /// Creates a copy of BusinessDetailDto with modified fields
  BusinessDetailDto copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? subCategory,
    String? phoneNumber,
    String? emailAddress,
    String? website,
    String? whatsApp,
    String? facebook,
    String? instagram,
    String? physicalAddress,
    double? latitude,
    double? longitude,
    String? logoUrl,
    String? coverImageUrl,
    double? rating,
    int? totalReviews,
    int? viewCount,
    bool? isFeatured,
    bool? isVerified,
    bool? isOpenNow,
    String? openNowText,
    List<OperatingHourDto>? operatingHours,
    List<SpecialOperatingHourDto>? specialOperatingHours,
    List<BusinessServiceDto>? services,
    List<BusinessImageDto>? images,
    List<ReviewDto>? reviews,
    List<DocumentDto>? documents,
  }) {
    return BusinessDetailDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      website: website ?? this.website,
      whatsApp: whatsApp ?? this.whatsApp,
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      viewCount: viewCount ?? this.viewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      openNowText: openNowText ?? this.openNowText,
      operatingHours: operatingHours ?? this.operatingHours,
      specialOperatingHours: specialOperatingHours ?? this.specialOperatingHours,
      services: services ?? this.services,
      images: images ?? this.images,
      reviews: reviews ?? this.reviews,
      documents: documents ?? this.documents,
    );
  }

  @override
  String toString() {
    return 'BusinessDetailDto(id: $id, name: $name, category: $category, totalReviews: $totalReviews, isFeatured: $isFeatured, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessDetailDto &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.isFeatured == isFeatured &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        category.hashCode ^
        isFeatured.hashCode ^
        isVerified.hashCode;
  }
}
