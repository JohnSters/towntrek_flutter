/// DTOs for public town admin banner and notice board (camelCase JSON from ASP.NET).
class PublicTownAdminProfileDto {
  const PublicTownAdminProfileDto({
    required this.displayName,
    required this.title,
    this.email,
    this.phone,
  });

  final String displayName;
  final String title;
  final String? email;
  final String? phone;

  factory PublicTownAdminProfileDto.fromJson(Map<String, dynamic> json) {
    return PublicTownAdminProfileDto(
      displayName: json['displayName'] as String? ?? 'Town Admin',
      title: json['title'] as String? ?? 'Town Admin',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

class PublicTownNoticeDto {
  const PublicTownNoticeDto({
    required this.id,
    required this.title,
    required this.body,
    this.contactEmail,
    this.contactPhone,
    this.eventStartDate,
    this.eventEndDate,
    this.physicalAddress,
    this.latitude,
    this.longitude,
    this.imageUrl,
    required this.publishedAtUtc,
    this.expiresAtUtc,
  });

  final int id;
  final String title;
  final String body;
  final String? contactEmail;
  final String? contactPhone;
  final DateTime? eventStartDate;
  final DateTime? eventEndDate;
  final String? physicalAddress;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final DateTime publishedAtUtc;
  final DateTime? expiresAtUtc;

  factory PublicTownNoticeDto.fromJson(Map<String, dynamic> json) {
    return PublicTownNoticeDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      eventStartDate: json['eventStartDate'] != null
          ? DateTime.parse(json['eventStartDate'] as String).toLocal()
          : null,
      eventEndDate: json['eventEndDate'] != null
          ? DateTime.parse(json['eventEndDate'] as String).toLocal()
          : null,
      physicalAddress: json['physicalAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      publishedAtUtc: DateTime.parse(json['publishedAtUtc'] as String).toUtc(),
      expiresAtUtc: json['expiresAtUtc'] != null
          ? DateTime.parse(json['expiresAtUtc'] as String).toUtc()
          : null,
    );
  }
}

class PublicTownNoticeListDto {
  const PublicTownNoticeListDto({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  final int totalCount;
  final int page;
  final int pageSize;
  final List<PublicTownNoticeDto> items;

  factory PublicTownNoticeListDto.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final list = <PublicTownNoticeDto>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(PublicTownNoticeDto.fromJson(e));
        }
      }
    }

    return PublicTownNoticeListDto(
      totalCount: (json['totalCount'] as num?)?.toInt() ?? list.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? list.length,
      items: list,
    );
  }
}
