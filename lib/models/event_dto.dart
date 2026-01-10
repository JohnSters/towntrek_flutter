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
    this.shortDescription,
    required this.eventType,
    this.status,
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
    // Handle both PascalCase (backend) and camelCase (our DTO) field names
    return EventDto(
      id: json['Id'] as int? ?? json['id'] as int,
      name: json['Name'] as String? ?? json['name'] as String,
      // Map Description if available (from detail view)
      description: json['Description'] as String? ?? json['description'] as String?,
      // Map ShortDescription explicitly
      shortDescription: json['ShortDescription'] as String? ?? json['shortDescription'] as String?,
      eventType: json['EventType'] as String? ?? json['eventType'] as String,
      status: json['Status'] as String? ?? json['status'] as String?,
      startDate: DateTime.parse(json['StartDate'] as String? ?? json['startDate'] as String),
      endDate: json['EndDate'] != null ? DateTime.parse(json['EndDate'] as String) :
               json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      startTime: json['StartTime']?.toString() ?? json['startTime'] as String?,
      endTime: json['EndTime']?.toString() ?? json['endTime'] as String?,
      venue: json['Venue'] as String? ?? json['venue'] as String?,
      physicalAddress: json['TownName'] as String? ?? json['townName'] as String? ?? 'Location TBA',
      latitude: null, // Not provided by EventCardViewModel
      longitude: null, // Not provided by EventCardViewModel
      isFreeEvent: json['IsFreeEvent'] as bool? ?? json['isFreeEvent'] as bool? ?? true,
      entryFeeAmount: json['EntryFeeAmount'] != null ? (json['EntryFeeAmount'] as num).toDouble() :
                      json['entryFeeAmount'] != null ? (json['entryFeeAmount'] as num).toDouble() : null,
      entryFeeCurrency: json['EntryFeeCurrency'] as String? ?? json['entryFeeCurrency'] as String?,
      logoUrl: json['LogoUrl'] as String? ?? json['logoUrl'] as String?,
      rating: json['AverageRating'] != null ? (json['AverageRating'] as num).toDouble() :
               json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalReviews: json['TotalReviews'] as int? ?? json['totalReviews'] as int? ?? 0,
      viewCount: json['ViewCount'] as int? ?? json['viewCount'] as int? ?? 0,
      isPriorityListing: false, // Not provided by EventCardViewModel, default to false
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
    String? shortDescription,
    String? eventType,
    String? status,
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
      shortDescription: shortDescription ?? this.shortDescription,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
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

  /// Get the effective end date/time of the event
  DateTime get effectiveEndDateTime {
    final end = endDate ?? startDate;
    // If there's an end time, assume the event ends at that time.
    // Otherwise, assume it ends at the end of the day (23:59).
    final timeString = endTime;
    final parts = (timeString ?? '').split(':');
    final hour = parts.isNotEmpty && parts[0].isNotEmpty ? int.tryParse(parts[0]) : null;
    final minute = parts.length > 1 && parts[1].isNotEmpty ? int.tryParse(parts[1]) : null;

    return DateTime(
      end.year,
      end.month,
      end.day,
      hour ?? 23,
      minute ?? 59,
    );
  }

  /// Check if the event has finished
  bool get isFinished {
    return status == 'Completed' || DateTime.now().isAfter(effectiveEndDateTime);
  }

  /// Get the number of days since the event finished (negative if not finished)
  int get daysSinceFinished {
    if (!isFinished) return -1;
    return DateTime.now().difference(effectiveEndDateTime).inDays;
  }

  /// Check if the event should be hidden (finished more than 2 days ago)
  bool get shouldHide {
    return daysSinceFinished > 2;
  }

  /// Check if the event should be greyed out (finished within the last 24 hours)
  bool get shouldGreyOut {
    return daysSinceFinished >= 0 && daysSinceFinished <= 1;
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
