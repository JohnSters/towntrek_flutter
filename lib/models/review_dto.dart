/// Review information for a business
class ReviewDto {
  final int id;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String userName;
  final bool isVerified;

  const ReviewDto({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.userName,
    required this.isVerified,
  });

  /// Creates a ReviewDto from JSON
  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      id: json['id'] as int,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: json['userName'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  /// Converts ReviewDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
      'isVerified': isVerified,
    };
  }

  /// Creates a copy of ReviewDto with modified fields
  ReviewDto copyWith({
    int? id,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? userName,
    bool? isVerified,
  }) {
    return ReviewDto(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  String toString() {
    return 'ReviewDto(id: $id, rating: $rating, userName: $userName, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReviewDto &&
        other.id == id &&
        other.rating == rating &&
        other.userName == userName;
  }

  @override
  int get hashCode {
    return id.hashCode ^ rating.hashCode ^ userName.hashCode;
  }
}
