import 'sub_category_with_count_dto.dart';

/// Category information with business counts for a specific town
class CategoryWithCountDto {
  final String key;
  final String name;
  final int businessCount;
  final List<SubCategoryWithCountDto> subCategories;

  const CategoryWithCountDto({
    required this.key,
    required this.name,
    required this.businessCount,
    required this.subCategories,
  });

  /// Creates a CategoryWithCountDto from JSON
  factory CategoryWithCountDto.fromJson(Map<String, dynamic> json) {
    return CategoryWithCountDto(
      key: json['key'] as String,
      name: json['name'] as String,
      businessCount: json['businessCount'] as int,
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) => SubCategoryWithCountDto.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  /// Converts CategoryWithCountDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'businessCount': businessCount,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
    };
  }

  /// Creates a copy of CategoryWithCountDto with modified fields
  CategoryWithCountDto copyWith({
    String? key,
    String? name,
    int? businessCount,
    List<SubCategoryWithCountDto>? subCategories,
  }) {
    return CategoryWithCountDto(
      key: key ?? this.key,
      name: name ?? this.name,
      businessCount: businessCount ?? this.businessCount,
      subCategories: subCategories ?? this.subCategories,
    );
  }

  @override
  String toString() {
    return 'CategoryWithCountDto(key: $key, name: $name, businessCount: $businessCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryWithCountDto &&
        other.key == key &&
        other.name == name &&
        other.businessCount == businessCount;
  }

  @override
  int get hashCode {
    return key.hashCode ^ name.hashCode ^ businessCount.hashCode;
  }
}
