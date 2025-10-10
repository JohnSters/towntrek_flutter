import 'sub_category_dto.dart';

/// Category information with subcategories
class CategoryDto {
  final String key;
  final String name;
  final List<SubCategoryDto> subCategories;

  const CategoryDto({
    required this.key,
    required this.name,
    required this.subCategories,
  });

  /// Creates a CategoryDto from JSON
  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      key: json['key'] as String,
      name: json['name'] as String,
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) => SubCategoryDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  /// Converts CategoryDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
    };
  }

  /// Creates a copy of CategoryDto with modified fields
  CategoryDto copyWith({
    String? key,
    String? name,
    List<SubCategoryDto>? subCategories,
  }) {
    return CategoryDto(
      key: key ?? this.key,
      name: name ?? this.name,
      subCategories: subCategories ?? this.subCategories,
    );
  }

  @override
  String toString() {
    return 'CategoryDto(key: $key, name: $name, subCategories: ${subCategories.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryDto &&
        other.key == key &&
        other.name == name;
  }

  @override
  int get hashCode {
    return key.hashCode ^ name.hashCode;
  }
}
