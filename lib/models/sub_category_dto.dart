/// Subcategory information
class SubCategoryDto {
  final String key;
  final String name;

  const SubCategoryDto({
    required this.key,
    required this.name,
  });

  /// Creates a SubCategoryDto from JSON
  factory SubCategoryDto.fromJson(Map<String, dynamic> json) {
    return SubCategoryDto(
      key: json['key'] as String,
      name: json['name'] as String,
    );
  }

  /// Converts SubCategoryDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
    };
  }

  /// Creates a copy of SubCategoryDto with modified fields
  SubCategoryDto copyWith({
    String? key,
    String? name,
  }) {
    return SubCategoryDto(
      key: key ?? this.key,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'SubCategoryDto(key: $key, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubCategoryDto &&
        other.key == key &&
        other.name == name;
  }

  @override
  int get hashCode {
    return key.hashCode ^ name.hashCode;
  }
}
