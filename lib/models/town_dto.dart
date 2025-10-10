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
    );
  }

  @override
  String toString() {
    return 'TownDto(id: $id, name: $name, province: $province, businessCount: $businessCount)';
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
