/// Subcategory information with business counts
class SubCategoryWithCountDto {
  final String key;
  final String name;
  final int businessCount;

  const SubCategoryWithCountDto({
    required this.key,
    required this.name,
    required this.businessCount,
  });

  /// Creates a SubCategoryWithCountDto from JSON
  factory SubCategoryWithCountDto.fromJson(Map<String, dynamic> json) {
    return SubCategoryWithCountDto(
      key: json['key'] as String,
      name: json['name'] as String,
      businessCount: json['businessCount'] as int,
    );
  }

  /// Converts SubCategoryWithCountDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'businessCount': businessCount,
    };
  }

  /// Creates a copy of SubCategoryWithCountDto with modified fields
  SubCategoryWithCountDto copyWith({
    String? key,
    String? name,
    int? businessCount,
  }) {
    return SubCategoryWithCountDto(
      key: key ?? this.key,
      name: name ?? this.name,
      businessCount: businessCount ?? this.businessCount,
    );
  }

  @override
  String toString() {
    return 'SubCategoryWithCountDto(key: $key, name: $name, businessCount: $businessCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubCategoryWithCountDto &&
        other.key == key &&
        other.name == name &&
        other.businessCount == businessCount;
  }

  @override
  int get hashCode {
    return key.hashCode ^ name.hashCode ^ businessCount.hashCode;
  }
}
