class ServiceSubCategoryDto {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final String? iconClass;
  final int serviceCount; // Added count

  const ServiceSubCategoryDto({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.iconClass,
    this.serviceCount = 0,
  });

  factory ServiceSubCategoryDto.fromJson(Map<String, dynamic> json) {
    return ServiceSubCategoryDto(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconClass: json['iconClass'] as String?,
      serviceCount: json['serviceCount'] as int? ?? 0,
    );
  }
}

class ServiceCategoryDto {
  final int id;
  final String name;
  final String? description;
  final String? iconClass;
  final List<ServiceSubCategoryDto> subCategories;
  final int serviceCount; // Added count

  const ServiceCategoryDto({
    required this.id,
    required this.name,
    this.description,
    this.iconClass,
    this.subCategories = const [],
    this.serviceCount = 0,
  });

  factory ServiceCategoryDto.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconClass: json['iconClass'] as String?,
      subCategories: (json['subCategories'] as List<dynamic>?)
              ?.map((e) => ServiceSubCategoryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      serviceCount: json['serviceCount'] as int? ?? 0,
    );
  }
}
