/// Date-based special operating hours override for a business (e.g. holiday closures)
class SpecialOperatingHourDto {
  final DateTime date;
  final String? openTime; // "HH:mm"
  final String? closeTime; // "HH:mm"
  final bool isClosed;
  final String? reason;
  final String? notes;

  const SpecialOperatingHourDto({
    required this.date,
    this.openTime,
    this.closeTime,
    required this.isClosed,
    this.reason,
    this.notes,
  });

  factory SpecialOperatingHourDto.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['date'];
    DateTime parsedDate;

    if (dateRaw is String) {
      parsedDate = DateTime.tryParse(dateRaw) ?? DateTime.now();
    } else {
      // Fallback: unexpected format
      parsedDate = DateTime.now();
    }

    return SpecialOperatingHourDto(
      date: parsedDate,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      isClosed: json['isClosed'] as bool? ?? false,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
      'reason': reason,
      'notes': notes,
    };
  }
}


