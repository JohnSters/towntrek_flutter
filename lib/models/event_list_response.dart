import 'event_dto.dart';

/// Response model for paginated event listings
class EventListResponse {
  final List<EventDto> events;
  final int totalCount;
  final int page;
  final int pageSize;
  /// Server field: rows returned this page (`returnedCount`); falls back to [events.length] for older APIs.
  final int returnedCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const EventListResponse({
    required this.events,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.returnedCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Creates an EventListResponse from JSON
  factory EventListResponse.fromJson(Map<String, dynamic> json) {
    final eventsList = (json['events'] as List<dynamic>? ?? json['Events'] as List<dynamic>? ?? [])
        .map((e) => EventDto.fromJson(e as Map<String, dynamic>))
        .toList();
    return EventListResponse(
      events: eventsList,
      totalCount: json['totalCount'] as int? ?? json['TotalCount'] as int? ?? 0,
      page: json['page'] as int? ?? json['Page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? json['PageSize'] as int? ?? 0,
      returnedCount: json['returnedCount'] as int? ??
          json['ReturnedCount'] as int? ??
          eventsList.length,
      totalPages: json['totalPages'] as int? ?? json['TotalPages'] as int? ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? json['HasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? json['HasPreviousPage'] as bool? ?? false,
    );
  }

  /// Converts EventListResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
      'returnedCount': returnedCount,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  /// Creates a copy of EventListResponse with modified fields
  EventListResponse copyWith({
    List<EventDto>? events,
    int? totalCount,
    int? page,
    int? pageSize,
    int? returnedCount,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return EventListResponse(
      events: events ?? this.events,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      returnedCount: returnedCount ?? this.returnedCount,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }

  @override
  String toString() {
    return 'EventListResponse(totalCount: $totalCount, page: $page, totalPages: $totalPages, events: ${events.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventListResponse &&
        other.totalCount == totalCount &&
        other.page == page &&
        other.totalPages == totalPages;
  }

  @override
  int get hashCode {
    return totalCount.hashCode ^ page.hashCode ^ totalPages.hashCode;
  }
}
