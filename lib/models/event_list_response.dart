import 'event_dto.dart';

/// Response model for paginated event listings
class EventListResponse {
  final List<EventDto> events;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const EventListResponse({
    required this.events,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Creates an EventListResponse from JSON
  factory EventListResponse.fromJson(Map<String, dynamic> json) {
    return EventListResponse(
      events: (json['events'] as List<dynamic>)
          .map((e) => EventDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }

  /// Converts EventListResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
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
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return EventListResponse(
      events: events ?? this.events,
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
