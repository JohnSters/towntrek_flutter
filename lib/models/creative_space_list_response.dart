import 'creative_space_dto.dart';

/// Creative spaces list response with pagination metadata
class CreativeSpaceListResponse {
  final List<CreativeSpaceDto> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool remoteHasNextPage;
  final bool hasPreviousPage;

  const CreativeSpaceListResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.remoteHasNextPage,
    required this.hasPreviousPage,
  });

  /// Creates a [CreativeSpaceListResponse] from JSON
  factory CreativeSpaceListResponse.fromJson(Map<String, dynamic> json) {
    final totalCount = json['totalCount'] as int? ??
        json['totalRecords'] as int? ??
        0;
    final page = json['page'] as int? ?? json['pageIndex'] as int? ?? 1;
    final pageSize = json['pageSize'] as int? ??
        json['pageSizeValue'] as int? ??
        json['limit'] as int? ??
        0;
    final totalPagesFromServer = json['totalPages'] as int? ??
        json['totalPagesCount'] as int? ??
        (pageSize > 0 ? (totalCount / pageSize).ceil() : 1);

    final items = (json['items'] as List<dynamic>?)
            ?.map((e) => CreativeSpaceDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        (json['creativeSpaces'] as List<dynamic>?)
            ?.map((e) => CreativeSpaceDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        (json['data'] as List<dynamic>?)
            ?.map((e) => CreativeSpaceDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    return CreativeSpaceListResponse(
      items: items,
      totalCount: totalCount == 0 ? items.length : totalCount,
      page: page,
      pageSize: pageSize == 0 ? items.length : pageSize,
      totalPages: totalPagesFromServer == 0 ? 1 : totalPagesFromServer,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      remoteHasNextPage: json['hasNextPage'] as bool? ??
          json['hasMore'] as bool? ??
          (page < totalPagesFromServer),
    );
  }

  /// Converts [CreativeSpaceListResponse] to JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  bool get hasNextPage {
    return remoteHasNextPage || (page < totalPages);
  }

  /// Creates a copy with modified fields
  CreativeSpaceListResponse copyWith({
    List<CreativeSpaceDto>? items,
    int? totalCount,
    int? page,
    int? pageSize,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return CreativeSpaceListResponse(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      remoteHasNextPage: hasNextPage ?? this.remoteHasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }
}
