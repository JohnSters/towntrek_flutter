/// Data transfer object for event information in listings
class EventDto {
  final int id;
  final String name;
  final String? description;
  final String eventType;
  final DateTime startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final String? venue;
  final String physicalAddress;
  final double? latitude;
  final double? longitude;
  final bool isFreeEvent;
  final double? entryFeeAmount;
  final String? entryFeeCurrency;
  final String? logoUrl;
  final double? rating;
  final int totalReviews;
  final int viewCount;
  final bool isPriorityListing;

  const EventDto({
    required this.id,
    required this.name,
    this.description,
    required this.eventType,
    required this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.venue,
    required this.physicalAddress,
    this.latitude,
    this.longitude,
    required this.isFreeEvent,
    this.entryFeeAmount,
    this.entryFeeCurrency,
    this.logoUrl,
    this.rating,
    required this.totalReviews,
    required this.viewCount,
    required this.isPriorityListing,
  });

  /// Creates an EventDto from JSON
  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      eventType: json['eventType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      venue: json['venue'] as String?,
      physicalAddress: json['physicalAddress'] as String,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      isFreeEvent: json['isFreeEvent'] as bool? ?? true,
      entryFeeAmount: json['entryFeeAmount'] != null ? (json['entryFeeAmount'] as num).toDouble() : null,
      entryFeeCurrency: json['entryFeeCurrency'] as String?,
      logoUrl: json['logoUrl'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalReviews: json['totalReviews'] as int,
      viewCount: json['viewCount'] as int,
      isPriorityListing: json['isPriorityListing'] as bool? ?? false,
    );
  }

  /// Converts EventDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'eventType': eventType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'venue': venue,
      'physicalAddress': physicalAddress,
      'latitude': latitude,
      'longitude': longitude,
      'isFreeEvent': isFreeEvent,
      'entryFeeAmount': entryFeeAmount,
      'entryFeeCurrency': entryFeeCurrency,
      'logoUrl': logoUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'viewCount': viewCount,
      'isPriorityListing': isPriorityListing,
    };
  }

  /// Creates a copy of EventDto with modified fields
  EventDto copyWith({
    int? id,
    String? name,
    String? description,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    String? venue,
    String? physicalAddress,
    double? latitude,
    double? longitude,
    bool? isFreeEvent,
    double? entryFeeAmount,
    String? entryFeeCurrency,
    String? logoUrl,
    double? rating,
    int? totalReviews,
    int? viewCount,
    bool? isPriorityListing,
  }) {
    return EventDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      venue: venue ?? this.venue,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFreeEvent: isFreeEvent ?? this.isFreeEvent,
      entryFeeAmount: entryFeeAmount ?? this.entryFeeAmount,
      entryFeeCurrency: entryFeeCurrency ?? this.entryFeeCurrency,
      logoUrl: logoUrl ?? this.logoUrl,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      viewCount: viewCount ?? this.viewCount,
      isPriorityListing: isPriorityListing ?? this.isPriorityListing,
    );
  }

  /// Get display date string
  String get displayDate {
    if (endDate != null) {
      return '${startDate.month}/${startDate.day} - ${endDate!.month}/${endDate!.day}, ${startDate.year}';
    }
    return '${startDate.month}/${startDate.day}, ${startDate.year}';
  }

  /// Get display price string
  String get displayPrice {
    if (isFreeEvent) {
      return 'Free';
    }
    if (entryFeeAmount != null) {
      return '${entryFeeAmount!.toStringAsFixed(2)} ${entryFeeCurrency ?? 'ZAR'}';
    }
    return 'Price TBA';
  }

  @override
  String toString() {
    return 'EventDto(id: $id, name: $name, eventType: $eventType, isFreeEvent: $isFreeEvent, isPriorityListing: $isPriorityListing)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventDto &&
        other.id == id &&
        other.name == name &&
        other.eventType == eventType &&
        other.isFreeEvent == isFreeEvent &&
        other.isPriorityListing == isPriorityListing;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        eventType.hashCode ^
        isFreeEvent.hashCode ^
        isPriorityListing.hashCode;
  }
}
