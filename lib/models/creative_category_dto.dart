import 'creative_sub_category_dto.dart';

/// Creative space category information
class CreativeCategoryDto {
  final int id;
  final String name;
  final String? key;
  final String? description;
  final String? iconClass;
  final int spaceCount;
  final List<CreativeSubCategoryDto> subCategories;

  const CreativeCategoryDto({
    required this.id,
    required this.name,
    this.key,
    this.description,
    this.iconClass,
    this.spaceCount = 0,
    this.subCategories = const [],
  });

  /// Creates a [CreativeCategoryDto] from JSON
  factory CreativeCategoryDto.fromJson(Map<String, dynamic> json) {
    final rawSubCategories = (json['subCategories'] as List<dynamic>?) ??
        (json['subcategories'] as List<dynamic>?) ??
        const [];

    return CreativeCategoryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      key: json['key'] as String?,
      description: json['description'] as String?,
      iconClass: json['iconClass'] as String?,
      spaceCount:
          json['spaceCount'] as int? ??
          json['creativeSpaceCount'] as int? ??
          json['businessCount'] as int? ??
          0,
      subCategories: rawSubCategories
          .map((e) => CreativeSubCategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts [CreativeCategoryDto] to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'key': key,
      'description': description,
      'iconClass': iconClass,
      'spaceCount': spaceCount,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
    };
  }

  /// Creates a copy with updated fields
  CreativeCategoryDto copyWith({
    int? id,
    String? name,
    String? key,
    String? description,
    String? iconClass,
    int? spaceCount,
    List<CreativeSubCategoryDto>? subCategories,
  }) {
    return CreativeCategoryDto(
      id: id ?? this.id,
      name: name ?? this.name,
      key: key ?? this.key,
      description: description ?? this.description,
      iconClass: iconClass ?? this.iconClass,
      spaceCount: spaceCount ?? this.spaceCount,
      subCategories: subCategories ?? this.subCategories,
    );
  }

  @override
  String toString() {
    return 'CreativeCategoryDto(id: $id, name: $name, subCategories: ${subCategories.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreativeCategoryDto &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}
