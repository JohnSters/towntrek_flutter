/// Service information for a business
class BusinessServiceDto {
  final String serviceType;
  final bool isAvailable;
  final String? description;

  const BusinessServiceDto({
    required this.serviceType,
    required this.isAvailable,
    this.description,
  });

  /// Creates a BusinessServiceDto from JSON
  factory BusinessServiceDto.fromJson(Map<String, dynamic> json) {
    return BusinessServiceDto(
      serviceType: json['serviceType'] as String,
      isAvailable: json['isAvailable'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  /// Converts BusinessServiceDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'isAvailable': isAvailable,
      'description': description,
    };
  }

  /// Creates a copy of BusinessServiceDto with modified fields
  BusinessServiceDto copyWith({
    String? serviceType,
    bool? isAvailable,
    String? description,
  }) {
    return BusinessServiceDto(
      serviceType: serviceType ?? this.serviceType,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'BusinessServiceDto(serviceType: $serviceType, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BusinessServiceDto &&
        other.serviceType == serviceType &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode {
    return serviceType.hashCode ^ isAvailable.hashCode;
  }
}
