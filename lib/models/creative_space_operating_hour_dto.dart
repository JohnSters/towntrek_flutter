/// Creative space operating hour information
class CreativeSpaceOperatingHourDto {
  final String dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isOpen;
  final bool isSpecialHours;
  final String? specialHoursNote;

  const CreativeSpaceOperatingHourDto({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.isOpen = false,
    this.isSpecialHours = false,
    this.specialHoursNote,
  });

  /// Creates a [CreativeSpaceOperatingHourDto] from JSON
  factory CreativeSpaceOperatingHourDto.fromJson(Map<String, dynamic> json) {
    return CreativeSpaceOperatingHourDto(
      dayOfWeek: json['dayOfWeek'].toString(),
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      isOpen: json['isOpen'] as bool? ?? false,
      isSpecialHours: json['isSpecialHours'] as bool? ?? false,
      specialHoursNote: json['specialHoursNote'] as String?,
    );
  }

  /// Converts [CreativeSpaceOperatingHourDto] to JSON
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

  /// Creates a copy with updated fields
  CreativeSpaceOperatingHourDto copyWith({
    String? dayOfWeek,
    String? openTime,
    String? closeTime,
    bool? isOpen,
    bool? isSpecialHours,
    String? specialHoursNote,
  }) {
    return CreativeSpaceOperatingHourDto(
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
    return 'CreativeSpaceOperatingHourDto(dayOfWeek: $dayOfWeek, openTime: $openTime, closeTime: $closeTime, isOpen: $isOpen)';
  }
}
