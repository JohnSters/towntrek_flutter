int _townInt(Map<String, dynamic> json, String camel, String pascal) {
  final v = json[camel] ?? json[pascal];
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim()) ?? 0;
  return 0;
}

/// Data transfer object for town information
class TownDto {
  final int id;
  final String name;
  final String province;
  final String? postalCode;
  final String? description;
  final int? population;
  final double? latitude;
  final double? longitude;
  final int businessCount;
  final int servicesCount;
  final int eventsCount;
  final int propertyListingCount;
  final int creativeSpaceCount;
  final int equipmentRentalBusinessCount;

  const TownDto({
    required this.id,
    required this.name,
    required this.province,
    this.postalCode,
    this.description,
    this.population,
    this.latitude,
    this.longitude,
    required this.businessCount,
    this.servicesCount = 0,
    this.eventsCount = 0,
    this.propertyListingCount = 0,
    this.creativeSpaceCount = 0,
    this.equipmentRentalBusinessCount = 0,
  });

  /// Creates a TownDto from JSON
  factory TownDto.fromJson(Map<String, dynamic> json) {
    return TownDto(
      id: json['id'] as int,
      name: json['name'] as String,
      province: json['province'] as String,
      postalCode: json['postalCode'] as String?,
      description: json['description'] as String?,
      population: json['population'] as int?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      businessCount: json['businessCount'] as int,
      servicesCount: (json['serviceCount'] as int?) ?? 0,
      eventsCount: (json['eventCount'] as int?) ?? 0,
      propertyListingCount: _townInt(
        json,
        'propertyListingCount',
        'PropertyListingCount',
      ),
      creativeSpaceCount: _townInt(
        json,
        'creativeSpaceCount',
        'CreativeSpaceCount',
      ),
      equipmentRentalBusinessCount: _townInt(
        json,
        'equipmentRentalBusinessCount',
        'EquipmentRentalBusinessCount',
      ),
    );
  }

  /// Converts TownDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'province': province,
      'postalCode': postalCode,
      'description': description,
      'population': population,
      'latitude': latitude,
      'longitude': longitude,
      'businessCount': businessCount,
      'serviceCount': servicesCount,
      'eventCount': eventsCount,
      'propertyListingCount': propertyListingCount,
      'creativeSpaceCount': creativeSpaceCount,
      'equipmentRentalBusinessCount': equipmentRentalBusinessCount,
    };
  }

  /// Creates a copy of TownDto with modified fields
  TownDto copyWith({
    int? id,
    String? name,
    String? province,
    String? postalCode,
    String? description,
    int? population,
    double? latitude,
    double? longitude,
    int? businessCount,
    int? servicesCount,
    int? eventsCount,
    int? propertyListingCount,
    int? creativeSpaceCount,
    int? equipmentRentalBusinessCount,
  }) {
    return TownDto(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      description: description ?? this.description,
      population: population ?? this.population,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      businessCount: businessCount ?? this.businessCount,
      servicesCount: servicesCount ?? this.servicesCount,
      eventsCount: eventsCount ?? this.eventsCount,
      propertyListingCount: propertyListingCount ?? this.propertyListingCount,
      creativeSpaceCount: creativeSpaceCount ?? this.creativeSpaceCount,
      equipmentRentalBusinessCount:
          equipmentRentalBusinessCount ?? this.equipmentRentalBusinessCount,
    );
  }

  @override
  String toString() {
    return 'TownDto(id: $id, name: $name, province: $province, businessCount: $businessCount, servicesCount: $servicesCount, eventsCount: $eventsCount, propertyListingCount: $propertyListingCount, creativeSpaceCount: $creativeSpaceCount, equipmentRentalBusinessCount: $equipmentRentalBusinessCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TownDto &&
        other.id == id &&
        other.name == name &&
        other.province == province;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ province.hashCode;
  }
}
