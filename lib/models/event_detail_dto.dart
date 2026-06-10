import 'event_image_dto.dart';
import 'event_review_dto.dart';
import 'event_type_detail_dto.dart';

/// Detailed event information for individual event pages
class EventDetailDto {
  final int id;
  final String name;
  final String? description;
  final String? shortDescription;
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

  // Additional detail fields
  final String? venueAddress;
  final String? phoneNumber;
  final String? emailAddress;
  final String? website;
  final String? ticketInfo;
  final bool requiresTickets;
  final String? eventProgram;
  final String? ageRestrictions;
  final bool hasParking;
  final bool hasRefreshments;
  final bool isOutdoorEvent;
  final bool hasWeatherBackup;
  final int? maxAttendees;
  final int? expectedAttendance;
  final String? organizerContact;
  final String status;
  final String? coverImageUrl;
  final List<EventImageDto> images;
  final List<EventReviewDto> reviews;
  final List<EventTypeDetailDto>? typeDetails;
  final bool isRecurring;
  final String? recurrencePattern;
  final String? recurrenceDaysOfWeek;
  final DateTime? nextOccurrenceDate;

  const EventDetailDto({
    required this.id,
    required this.name,
    this.description,
    this.shortDescription,
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
    this.venueAddress,
    this.phoneNumber,
    this.emailAddress,
    this.website,
    this.ticketInfo,
    required this.requiresTickets,
    this.eventProgram,
    this.ageRestrictions,
    required this.hasParking,
    required this.hasRefreshments,
    required this.isOutdoorEvent,
    required this.hasWeatherBackup,
    this.maxAttendees,
    this.expectedAttendance,
    this.organizerContact,
    required this.status,
    this.coverImageUrl,
    required this.images,
    required this.reviews,
    this.typeDetails,
    this.isRecurring = false,
    this.recurrencePattern,
    this.recurrenceDaysOfWeek,
    this.nextOccurrenceDate,
  });

  /// Creates an EventDetailDto from JSON
  factory EventDetailDto.fromJson(Map<String, dynamic> json) {
    T? pick<T>(String camel, String pascal) {
      final v = json[camel] ?? json[pascal];
      return v as T?;
    }

    String reqStr(String camel, String pascal) =>
        pick<String>(camel, pascal) ?? '';

    int reqInt(String camel, String pascal) =>
        pick<int>(camel, pascal) ?? (pick<num>(camel, pascal)?.toInt() ?? 0);

    bool pickBool(String camel, String pascal, {bool d = false}) =>
        pick<bool>(camel, pascal) ?? d;

    final startRaw = json['startDate'] ?? json['StartDate'];
    final endRaw = json['endDate'] ?? json['EndDate'];

    double? coord(String camel, String pascal) {
      final v = json[camel] ?? json[pascal];
      if (v == null) return null;
      return (v as num).toDouble();
    }

    final imgs = json['images'] as List<dynamic>? ?? json['Images'] as List<dynamic>? ?? [];
    final revs = json['reviews'] as List<dynamic>? ?? json['Reviews'] as List<dynamic>? ?? [];
    final typeRaw = json['typeDetails'] as List<dynamic>? ?? json['TypeDetails'] as List<dynamic>?;

    DateTime? nextOccurrence(String camel, String pascal) {
      final raw = json[camel] ?? json[pascal];
      if (raw == null) return null;
      return DateTime.parse(raw as String);
    }

    return EventDetailDto(
      id: reqInt('id', 'Id'),
      name: reqStr('name', 'Name'),
      description: pick<String>('description', 'Description'),
      shortDescription: pick<String>('shortDescription', 'ShortDescription'),
      eventType: reqStr('eventType', 'EventType'),
      startDate: DateTime.parse(startRaw as String),
      endDate: endRaw != null ? DateTime.parse(endRaw as String) : null,
      startTime: pick<String>('startTime', 'StartTime'),
      endTime: pick<String>('endTime', 'EndTime'),
      venue: pick<String>('venue', 'Venue'),
      physicalAddress: reqStr('physicalAddress', 'PhysicalAddress'),
      latitude: coord('latitude', 'Latitude'),
      longitude: coord('longitude', 'Longitude'),
      isFreeEvent: pickBool('isFreeEvent', 'IsFreeEvent', d: true),
      entryFeeAmount: pick<num>('entryFeeAmount', 'EntryFeeAmount')?.toDouble(),
      entryFeeCurrency: pick<String>('entryFeeCurrency', 'EntryFeeCurrency'),
      logoUrl: pick<String>('logoUrl', 'LogoUrl'),
      rating: coord('rating', 'Rating'),
      totalReviews: reqInt('totalReviews', 'TotalReviews'),
      viewCount: reqInt('viewCount', 'ViewCount'),
      isPriorityListing: pickBool('isPriorityListing', 'IsPriorityListing') ||
          pickBool('isFeatured', 'IsFeatured'),
      venueAddress: pick<String>('venueAddress', 'VenueAddress'),
      phoneNumber: pick<String>('phoneNumber', 'PhoneNumber'),
      emailAddress: pick<String>('emailAddress', 'EmailAddress'),
      website: pick<String>('website', 'Website'),
      ticketInfo: pick<String>('ticketInfo', 'TicketInfo'),
      requiresTickets: pickBool('requiresTickets', 'RequiresTickets'),
      eventProgram: pick<String>('eventProgram', 'EventProgram'),
      ageRestrictions: pick<String>('ageRestrictions', 'AgeRestrictions'),
      hasParking: pickBool('hasParking', 'HasParking'),
      hasRefreshments: pickBool('hasRefreshments', 'HasRefreshments'),
      isOutdoorEvent: pickBool('isOutdoorEvent', 'IsOutdoorEvent'),
      hasWeatherBackup: pickBool('hasWeatherBackup', 'HasWeatherBackup'),
      maxAttendees: pick<int>('maxAttendees', 'MaxAttendees'),
      expectedAttendance: pick<int>('expectedAttendance', 'ExpectedAttendance'),
      organizerContact: pick<String>('organizerContact', 'OrganizerContact'),
      status: pick<String>('status', 'Status') ?? 'Draft',
      coverImageUrl: pick<String>('coverImageUrl', 'CoverImageUrl'),
      images:
          imgs.map((e) => EventImageDto.fromJson(e as Map<String, dynamic>)).toList(),
      reviews:
          revs.map((e) => EventReviewDto.fromJson(e as Map<String, dynamic>)).toList(),
      typeDetails: typeRaw
          ?.map((e) => EventTypeDetailDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      isRecurring: pickBool('isRecurring', 'IsRecurring'),
      recurrencePattern: pick<String>('recurrencePattern', 'RecurrencePattern'),
      recurrenceDaysOfWeek: pick<String>('recurrenceDaysOfWeek', 'RecurrenceDaysOfWeek'),
      nextOccurrenceDate: nextOccurrence('nextOccurrenceDate', 'NextOccurrenceDate'),
    );
  }

  /// Converts EventDetailDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
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
      'venueAddress': venueAddress,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'website': website,
      'ticketInfo': ticketInfo,
      'requiresTickets': requiresTickets,
      'eventProgram': eventProgram,
      'ageRestrictions': ageRestrictions,
      'hasParking': hasParking,
      'hasRefreshments': hasRefreshments,
      'isOutdoorEvent': isOutdoorEvent,
      'hasWeatherBackup': hasWeatherBackup,
      'maxAttendees': maxAttendees,
      'expectedAttendance': expectedAttendance,
      'organizerContact': organizerContact,
      'status': status,
      'coverImageUrl': coverImageUrl,
      'images': images.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'typeDetails': typeDetails?.map((e) => e.toJson()).toList(),
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
      'recurrenceDaysOfWeek': recurrenceDaysOfWeek,
      'nextOccurrenceDate': nextOccurrenceDate?.toIso8601String(),
    };
  }

  /// Creates a copy of EventDetailDto with modified fields
  EventDetailDto copyWith({
    int? id,
    String? name,
    String? description,
    String? shortDescription,
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
    String? venueAddress,
    String? phoneNumber,
    String? emailAddress,
    String? website,
    String? ticketInfo,
    bool? requiresTickets,
    String? eventProgram,
    String? ageRestrictions,
    bool? hasParking,
    bool? hasRefreshments,
    bool? isOutdoorEvent,
    bool? hasWeatherBackup,
    int? maxAttendees,
    int? expectedAttendance,
    String? organizerContact,
    String? status,
    String? coverImageUrl,
    List<EventImageDto>? images,
    List<EventReviewDto>? reviews,
    List<EventTypeDetailDto>? typeDetails,
    bool? isRecurring,
    String? recurrencePattern,
    String? recurrenceDaysOfWeek,
    DateTime? nextOccurrenceDate,
  }) {
    return EventDetailDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
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
      venueAddress: venueAddress ?? this.venueAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      website: website ?? this.website,
      ticketInfo: ticketInfo ?? this.ticketInfo,
      requiresTickets: requiresTickets ?? this.requiresTickets,
      eventProgram: eventProgram ?? this.eventProgram,
      ageRestrictions: ageRestrictions ?? this.ageRestrictions,
      hasParking: hasParking ?? this.hasParking,
      hasRefreshments: hasRefreshments ?? this.hasRefreshments,
      isOutdoorEvent: isOutdoorEvent ?? this.isOutdoorEvent,
      hasWeatherBackup: hasWeatherBackup ?? this.hasWeatherBackup,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      expectedAttendance: expectedAttendance ?? this.expectedAttendance,
      organizerContact: organizerContact ?? this.organizerContact,
      status: status ?? this.status,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      images: images ?? this.images,
      reviews: reviews ?? this.reviews,
      typeDetails: typeDetails ?? this.typeDetails,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      recurrenceDaysOfWeek: recurrenceDaysOfWeek ?? this.recurrenceDaysOfWeek,
      nextOccurrenceDate: nextOccurrenceDate ?? this.nextOccurrenceDate,
    );
  }

  @override
  String toString() {
    return 'EventDetailDto(id: $id, name: $name, eventType: $eventType, status: $status, totalReviews: $totalReviews, isPriorityListing: $isPriorityListing)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventDetailDto &&
        other.id == id &&
        other.name == name &&
        other.eventType == eventType &&
        other.status == status &&
        other.isPriorityListing == isPriorityListing;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        eventType.hashCode ^
        status.hashCode ^
        isPriorityListing.hashCode;
  }
}
