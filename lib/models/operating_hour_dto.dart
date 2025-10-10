/// Operating hours information for a business
class OperatingHourDto {
  final String dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isOpen;
  final bool isSpecialHours;
  final String? specialHoursNote;

  const OperatingHourDto({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isOpen,
    required this.isSpecialHours,
    this.specialHoursNote,
  });

  /// Creates an OperatingHourDto from JSON
  factory OperatingHourDto.fromJson(Map<String, dynamic> json) {
    return OperatingHourDto(
      dayOfWeek: json['dayOfWeek'] as String,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      isOpen: json['isOpen'] as bool,
      isSpecialHours: json['isSpecialHours'] as bool,
      specialHoursNote: json['specialHoursNote'] as String?,
    );
  }

  /// Converts OperatingHourDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'isOpen': isOpen,
      'isSpecialHours': isSpecialHours,
      'specialHoursNote': specialHoursNote,
    };
  }

  /// Creates a copy of OperatingHourDto with modified fields
  OperatingHourDto copyWith({
    String? dayOfWeek,
    String? openTime,
    String? closeTime,
    bool? isOpen,
    bool? isSpecialHours,
    String? specialHoursNote,
  }) {
    return OperatingHourDto(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
      isSpecialHours: isSpecialHours ?? this.isSpecialHours,
      specialHoursNote: specialHoursNote ?? this.specialHoursNote,
    );
  }

  @override
  String toString() {
    return 'OperatingHourDto(dayOfWeek: $dayOfWeek, openTime: $openTime, closeTime: $closeTime, isOpen: $isOpen, isSpecialHours: $isSpecialHours)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OperatingHourDto &&
        other.dayOfWeek == dayOfWeek &&
        other.openTime == openTime &&
        other.closeTime == closeTime &&
        other.isOpen == isOpen &&
        other.isSpecialHours == isSpecialHours;
  }

  @override
  int get hashCode {
    return dayOfWeek.hashCode ^
        openTime.hashCode ^
        closeTime.hashCode ^
        isOpen.hashCode ^
        isSpecialHours.hashCode;
  }
}
