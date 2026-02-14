/// Event type information for filtering and categorization
class EventTypeDto {
  final String key;
  final String name;
  final String? description;

  const EventTypeDto({
    required this.key,
    required this.name,
    this.description,
  });

  /// Creates an EventTypeDto from JSON
  factory EventTypeDto.fromJson(Map<String, dynamic> json) {
    return EventTypeDto(
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  /// Converts EventTypeDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'description': description,
    };
  }

  /// Creates a copy of EventTypeDto with modified fields
  EventTypeDto copyWith({
    String? key,
    String? name,
    String? description,
  }) {
    return EventTypeDto(
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'EventTypeDto(key: $key, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventTypeDto &&
        other.key == key &&
        other.name == name;
  }

  @override
  int get hashCode {
    return key.hashCode ^ name.hashCode;
  }
}
