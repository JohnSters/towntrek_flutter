import 'parcel_dto.dart';
import 'town_dto.dart';

int _memberEnumInt(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

enum MemberTrustLevel { newMember, community, trusted }

MemberTrustLevel _trustLevelFromJson(dynamic value) {
  switch (_memberEnumInt(value, 1)) {
    case 2:
      return MemberTrustLevel.community;
    case 3:
      return MemberTrustLevel.trusted;
    default:
      return MemberTrustLevel.newMember;
  }
}

class MemberProfileDto {
  final String userId;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final MemberTrustLevel trustLevel;
  final double averageRating;
  final int completedDeliveries;
  final TownDto? primaryTown;
  final List<TownDto> secondaryTowns;

  const MemberProfileDto({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.trustLevel,
    required this.averageRating,
    required this.completedDeliveries,
    required this.primaryTown,
    required this.secondaryTowns,
  });

  factory MemberProfileDto.fromJson(Map<String, dynamic> json) {
    final secondary = (json['secondaryTowns'] as List<dynamic>? ?? const []);
    return MemberProfileDto(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String? ?? 'TownTrek member',
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      trustLevel: _trustLevelFromJson(json['trustLevel']),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      completedDeliveries: (json['completedDeliveries'] as num?)?.toInt() ?? 0,
      primaryTown: json['primaryTown'] is Map<String, dynamic>
          ? TownDto.fromJson(json['primaryTown'] as Map<String, dynamic>)
          : null,
      secondaryTowns: secondary
          .map((item) => TownDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MemberActivityDto {
  final List<ParcelSummaryDto> myRequests;
  final List<ParcelSummaryDto> myDeliveries;

  const MemberActivityDto({
    required this.myRequests,
    required this.myDeliveries,
  });

  factory MemberActivityDto.fromJson(Map<String, dynamic> json) {
    final requests = (json['myRequests'] as List<dynamic>? ?? const []);
    final deliveries = (json['myDeliveries'] as List<dynamic>? ?? const []);
    return MemberActivityDto(
      myRequests: requests
          .map((item) => ParcelSummaryDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      myDeliveries: deliveries
          .map((item) => ParcelSummaryDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
