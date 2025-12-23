import 'package:intl/intl.dart';
import 'event_image_dto.dart';
import 'event_review_dto.dart';

/// Detailed event information for individual event pages
class EventDetailDto {
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

  const EventDetailDto({
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
  });

  /// Creates an EventDetailDto from JSON
  factory EventDetailDto.fromJson(Map<String, dynamic> json) {
    return EventDetailDto(
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
      venueAddress: json['venueAddress'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      emailAddress: json['emailAddress'] as String?,
      website: json['website'] as String?,
      ticketInfo: json['ticketInfo'] as String?,
      requiresTickets: json['requiresTickets'] as bool? ?? false,
      eventProgram: json['eventProgram'] as String?,
      ageRestrictions: json['ageRestrictions'] as String?,
      hasParking: json['hasParking'] as bool? ?? false,
      hasRefreshments: json['hasRefreshments'] as bool? ?? false,
      isOutdoorEvent: json['isOutdoorEvent'] as bool? ?? false,
      hasWeatherBackup: json['hasWeatherBackup'] as bool? ?? false,
      maxAttendees: json['maxAttendees'] as int?,
      expectedAttendance: json['expectedAttendance'] as int?,
      organizerContact: json['organizerContact'] as String?,
      status: json['status'] as String? ?? 'Draft',
      coverImageUrl: json['coverImageUrl'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => EventImageDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => EventReviewDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  /// Converts EventDetailDto to JSON
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
    };
  }

  /// Creates a copy of EventDetailDto with modified fields
  EventDetailDto copyWith({
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
  }) {
    return EventDetailDto(
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
    );
  }

  // Getters for display
  String get displayDate {
    final formatter = DateFormat('MMM d, yyyy');
    if (endDate != null && 
        endDate!.year != 1 && 
        (startDate.year != endDate!.year || startDate.month != endDate!.month || startDate.day != endDate!.day)) {
       return '${formatter.format(startDate)} - ${formatter.format(endDate!)}';
    }
    return formatter.format(startDate);
  }

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
