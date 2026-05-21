import 'dart:convert';

/// Type-specific extension row on event detail responses (e.g. market stalls).
class EventTypeDetailDto {
  final int id;
  final String name;
  final String? description;
  final int displayOrder;
  final String? metadata;

  const EventTypeDetailDto({
    required this.id,
    required this.name,
    this.description,
    required this.displayOrder,
    this.metadata,
  });

  factory EventTypeDetailDto.fromJson(Map<String, dynamic> json) {
    return EventTypeDetailDto(
      id: json['id'] as int? ?? json['Id'] as int? ?? 0,
      name: json['name'] as String? ?? json['Name'] as String? ?? '',
      description: json['description'] as String? ?? json['Description'] as String?,
      displayOrder: json['displayOrder'] as int? ?? json['DisplayOrder'] as int? ?? 0,
      metadata: json['metadata'] as String? ?? json['Metadata'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'displayOrder': displayOrder,
      'metadata': metadata,
    };
  }

  String? get category => _readMetadataString('category');

  String? get priceRange => _readMetadataString('priceRange');

  String? _readMetadataString(String key) {
    final raw = metadata;
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
