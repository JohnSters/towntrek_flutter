import 'operating_hour_dto.dart';
import 'special_operating_hour_dto.dart';

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
  final String physicalAddress;
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

  /// From API when hours are not used for client-side recompute.
  final bool? isOpenNow;

  final List<OperatingHourDto>? _operatingHours;
  final List<SpecialOperatingHourDto>? _specialOperatingHours;

  /// Never null (empty when missing / hot-reload legacy instances).
  List<OperatingHourDto> get operatingHours => _operatingHours ?? const [];

  /// Never null (empty when missing / hot-reload legacy instances).
  List<SpecialOperatingHourDto> get specialOperatingHours =>
      _specialOperatingHours ?? const [];

  BusinessDto({
    required this.id,
    required this.name,
    required this.description,
    this.shortDescription,
    required this.category,
    this.subCategory,
    this.phoneNumber,
    this.emailAddress,
    this.website,
    required this.physicalAddress,
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
    this.isOpenNow,
    List<OperatingHourDto>? operatingHours,
    List<SpecialOperatingHourDto>? specialOperatingHours,
  })  : _operatingHours = operatingHours,
        _specialOperatingHours = specialOperatingHours;

  /// Creates a BusinessDto from JSON
  factory BusinessDto.fromJson(Map<String, dynamic> json) {
    return BusinessDto(
      id: (json['id'] ?? json['Id']) as int,
      name: (json['name'] ?? json['Name']) as String,
      description: (json['description'] ?? json['Description']) as String? ?? '',
      shortDescription: (json['shortDescription'] ?? json['ShortDescription']) as String?,
      category: (json['category'] ?? json['Category']) as String,
      subCategory: (json['subCategory'] ?? json['SubCategory']) as String?,
      phoneNumber: (json['phoneNumber'] ?? json['PhoneNumber']) as String?,
      emailAddress: (json['emailAddress'] ?? json['EmailAddress']) as String?,
      website: (json['website'] ?? json['Website']) as String?,
      physicalAddress: (json['physicalAddress'] ?? json['PhysicalAddress']) as String? ?? '',
      latitude: _readDouble(json['latitude'] ?? json['Latitude']),
      longitude: _readDouble(json['longitude'] ?? json['Longitude']),
      logoUrl: (json['logoUrl'] ?? json['LogoUrl']) as String?,
      coverImageUrl: (json['coverImageUrl'] ?? json['CoverImageUrl']) as String?,
      rating: _readDouble(json['rating'] ?? json['Rating']),
      totalReviews: _readInt(json['totalReviews'] ?? json['TotalReviews']) ?? 0,
      viewCount: _readInt(json['viewCount'] ?? json['ViewCount']) ?? 0,
      isFeatured: (json['isFeatured'] ?? json['IsFeatured']) as bool? ?? false,
      isVerified: (json['isVerified'] ?? json['IsVerified']) as bool? ?? false,
      distanceKm: _readDouble(json['distanceKm'] ?? json['DistanceKm']),
      isOpenNow: _readBoolNullable(json['isOpenNow'] ?? json['IsOpenNow']),
      operatingHours: _parseOperatingHoursList(
        json['operatingHours'] ?? json['OperatingHours'],
      ),
      specialOperatingHours: specialOperatingHoursListFromJson(
        json['specialOperatingHours'] ?? json['SpecialOperatingHours'],
      ),
    );
  }

  static double? _readDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return null;
  }

  static int? _readInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.round();
    return null;
  }

  static bool? _readBoolNullable(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return null;
  }

  static List<OperatingHourDto>? _parseOperatingHoursList(dynamic raw) {
    if (raw == null) return null;
    if (raw is! List) return const [];
    return raw
        .map((e) => OperatingHourDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Converts a BusinessDto to JSON
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
      'isOpenNow': isOpenNow,
      'operatingHours': operatingHours.map((e) => e.toJson()).toList(),
      'specialOperatingHours': specialOperatingHours.map((e) => e.toJson()).toList(),
    };
  }

  /// Creates a copy of a BusinessDto with modified fields
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
    bool? isOpenNow,
    List<OperatingHourDto>? operatingHours,
    List<SpecialOperatingHourDto>? specialOperatingHours,
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
      isOpenNow: isOpenNow ?? this.isOpenNow,
      operatingHours: operatingHours ?? _operatingHours,
      specialOperatingHours: specialOperatingHours ?? _specialOperatingHours,
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
