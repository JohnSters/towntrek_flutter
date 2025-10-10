/// Data transfer object for town information
class TownDto {
  final int id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  const TownDto({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    required this.isActive,
  });

  /// Creates a TownDto from JSON
  factory TownDto.fromJson(Map<String, dynamic> json) {
    return TownDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      isActive: json['isActive'] as bool,
    );
  }

  /// Converts TownDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
    };
  }

  /// Creates a copy of TownDto with modified fields
  TownDto copyWith({
    int? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) {
    return TownDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'TownDto(id: $id, name: $name, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TownDto &&
        other.id == id &&
        other.name == name &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ isActive.hashCode;
  }
}
