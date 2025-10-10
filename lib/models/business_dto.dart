/// Data transfer object for business information in listings
class BusinessDto {
  final int id;
  final String name;
  final String description;
  final String? shortDescription;
  final String category;
  final String? subCategory;
  final String? phoneNumber;
  final String? emailAddress;
  final String? website;
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
  final double? distanceKm;

  const BusinessDto({
    required this.id,
    required this.name,
    required this.description,
    this.shortDescription,
    required this.category,
    this.subCategory,
    this.phoneNumber,
    this.emailAddress,
    this.website,
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
    this.distanceKm,
  });

  /// Creates a BusinessDto from JSON
  factory BusinessDto.fromJson(Map<String, dynamic> json) {
    return BusinessDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      shortDescription: json['shortDescription'] as String?,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      emailAddress: json['emailAddress'] as String?,
      website: json['website'] as String?,
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
      distanceKm: json['distanceKm'] != null ? (json['distanceKm'] as num).toDouble() : null,
    );
  }

  /// Converts BusinessDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
      'category': category,
      'subCategory': subCategory,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'website': website,
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
      'distanceKm': distanceKm,
    };
  }

  /// Creates a copy of BusinessDto with modified fields
  BusinessDto copyWith({
    int? id,
    String? name,
    String? description,
    String? shortDescription,
    String? category,
    String? subCategory,
    String? phoneNumber,
    String? emailAddress,
    String? website,
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
    double? distanceKm,
  }) {
    return BusinessDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      website: website ?? this.website,
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
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  @override
  String toString() {
    return 'BusinessDto(id: $id, name: $name, category: $category, isFeatured: $isFeatured, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessDto &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.category == category &&
        other.isFeatured == isFeatured &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        category.hashCode ^
        isFeatured.hashCode ^
        isVerified.hashCode;
  }
}
