/// Data transfer object for event information in listings
class EventDto {
  final int id;
  final String name;
  final String? description;
  final String? shortDescription;
  final String eventType;
  final String? status;
  final DateTime startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final String? venue;
  final String physicalAddress;
  /// Town label from API listing cards (`townName`).
  final String? townName;
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
  final bool isRecurring;
  final DateTime? nextOccurrenceDate;

  const EventDto({
    required this.id,
    required this.name,
    this.description,
    this.shortDescription,
    required this.eventType,
    this.status,
    required this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.venue,
    required this.physicalAddress,
    this.townName,
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
    this.isRecurring = false,
    this.nextOccurrenceDate,
  });

  /// Creates an EventDto from JSON
  factory EventDto.fromJson(Map<String, dynamic> json) {
    final townNm = json['TownName'] as String? ?? json['townName'] as String?;
    final street = (json['PhysicalAddress'] as String? ?? json['physicalAddress'] as String?)?.trim();
    final townTrim = townNm?.trim();
    final resolvedAddress = (street != null && street.isNotEmpty)
        ? street
        : (townTrim != null && townTrim.isNotEmpty ? townTrim : 'Location TBA');

    double? coord(String pascal, String camel) {
      final v = json[pascal] ?? json[camel];
      if (v == null) return null;
      return (v as num).toDouble();
    }

    final featured =
        json['IsFeatured'] as bool? ??
        json['isFeatured'] as bool? ??
        json['IsPriorityListing'] as bool? ??
        json['isPriorityListing'] as bool? ??
        false;

    DateTime? nextOccurrence(String camel, String pascal) {
      final raw = json[camel] ?? json[pascal];
      if (raw == null) return null;
      return DateTime.parse(raw as String);
    }

    return EventDto(
      id: json['Id'] as int? ?? json['id'] as int,
      name: json['Name'] as String? ?? json['name'] as String,
      description: json['Description'] as String? ?? json['description'] as String?,
      shortDescription: json['ShortDescription'] as String? ?? json['shortDescription'] as String?,
      eventType: json['EventType'] as String? ?? json['eventType'] as String,
      status: json['Status'] as String? ?? json['status'] as String?,
      startDate: DateTime.parse(json['StartDate'] as String? ?? json['startDate'] as String),
      endDate: json['EndDate'] != null ? DateTime.parse(json['EndDate'] as String) :
               json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      startTime: json['StartTime']?.toString() ?? json['startTime'] as String?,
      endTime: json['EndTime']?.toString() ?? json['endTime'] as String?,
      venue: json['Venue'] as String? ?? json['venue'] as String?,
      physicalAddress: resolvedAddress,
      townName: (townTrim != null && townTrim.isNotEmpty) ? townTrim : null,
      latitude: coord('Latitude', 'latitude'),
      longitude: coord('Longitude', 'longitude'),
      isFreeEvent: json['IsFreeEvent'] as bool? ?? json['isFreeEvent'] as bool? ?? true,
      entryFeeAmount: json['EntryFeeAmount'] != null ? (json['EntryFeeAmount'] as num).toDouble() :
                      json['entryFeeAmount'] != null ? (json['entryFeeAmount'] as num).toDouble() : null,
      entryFeeCurrency: json['EntryFeeCurrency'] as String? ?? json['entryFeeCurrency'] as String?,
      logoUrl: json['LogoUrl'] as String? ?? json['logoUrl'] as String?,
      rating: json['AverageRating'] != null ? (json['AverageRating'] as num).toDouble() :
               json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalReviews: json['TotalReviews'] as int? ?? json['totalReviews'] as int? ?? 0,
      viewCount: json['ViewCount'] as int? ?? json['viewCount'] as int? ?? 0,
      isPriorityListing: featured,
      isRecurring: json['IsRecurring'] as bool? ?? json['isRecurring'] as bool? ?? false,
      nextOccurrenceDate: nextOccurrence('nextOccurrenceDate', 'NextOccurrenceDate'),
    );
  }

  /// Converts EventDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
      'eventType': eventType,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'venue': venue,
      'physicalAddress': physicalAddress,
      'townName': townName,
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
      'isRecurring': isRecurring,
      'nextOccurrenceDate': nextOccurrenceDate?.toIso8601String(),
    };
  }

  /// Creates a copy of EventDto with modified fields
  EventDto copyWith({
    int? id,
    String? name,
    String? description,
    String? shortDescription,
    String? eventType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    String? venue,
    String? physicalAddress,
    String? townName,
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
    bool? isRecurring,
    DateTime? nextOccurrenceDate,
  }) {
    return EventDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      venue: venue ?? this.venue,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      townName: townName ?? this.townName,
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
      isRecurring: isRecurring ?? this.isRecurring,
      nextOccurrenceDate: nextOccurrenceDate ?? this.nextOccurrenceDate,
    );
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
