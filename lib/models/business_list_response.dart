import 'business_dto.dart';

/// Response model for paginated business listings
class BusinessListResponse {
  final List<BusinessDto> businesses;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const BusinessListResponse({
    required this.businesses,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Creates a BusinessListResponse from JSON
  factory BusinessListResponse.fromJson(Map<String, dynamic> json) {
    return BusinessListResponse(
      businesses: (json['businesses'] as List<dynamic>)
          .map((e) => BusinessDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
    );
  }

  /// Converts BusinessListResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'businesses': businesses.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  /// Creates a copy of BusinessListResponse with modified fields
  BusinessListResponse copyWith({
    List<BusinessDto>? businesses,
    int? totalCount,
    int? page,
    int? pageSize,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return BusinessListResponse(
      businesses: businesses ?? this.businesses,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }

  @override
  String toString() {
    return 'BusinessListResponse(totalCount: $totalCount, page: $page, totalPages: $totalPages, businesses: ${businesses.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessListResponse &&
        other.totalCount == totalCount &&
        other.page == page &&
        other.totalPages == totalPages;
  }

  @override
  int get hashCode {
    return totalCount.hashCode ^ page.hashCode ^ totalPages.hashCode;
  }
}
