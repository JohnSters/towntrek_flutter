/// Creative space sub-category information
class CreativeSubCategoryDto {
  final int id;
  final int categoryId;
  final String name;
  final String? key;
  final String? description;
  final int spaceCount;

  const CreativeSubCategoryDto({
    required this.id,
    required this.categoryId,
    required this.name,
    this.key,
    this.description,
    this.spaceCount = 0,
  });

  /// Creates a [CreativeSubCategoryDto] from JSON
  factory CreativeSubCategoryDto.fromJson(Map<String, dynamic> json) {
    return CreativeSubCategoryDto(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      name: json['name'] as String,
      key: json['key'] as String?,
      description: json['description'] as String?,
      spaceCount:
          json['spaceCount'] as int? ??
          json['creativeSpaceCount'] as int? ??
          json['businessCount'] as int? ??
          0,
    );
  }

  /// Converts [CreativeSubCategoryDto] to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'key': key,
      'description': description,
      'spaceCount': spaceCount,
    };
  }

  /// Creates a copy with updated fields
  CreativeSubCategoryDto copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? key,
    String? description,
    int? spaceCount,
  }) {
    return CreativeSubCategoryDto(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      key: key ?? this.key,
      description: description ?? this.description,
      spaceCount: spaceCount ?? this.spaceCount,
    );
  }

  @override
  String toString() {
    return 'CreativeSubCategoryDto(id: $id, name: $name, spaceCount: $spaceCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreativeSubCategoryDto &&
        other.id == id &&
        other.name == name &&
        other.spaceCount == spaceCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ spaceCount.hashCode;
  }
}
