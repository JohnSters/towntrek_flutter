/// Review information for an event
class EventReviewDto {
  final int id;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String? userName;
  final bool isApproved;

  const EventReviewDto({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
    required this.isApproved,
  });

  /// Creates an EventReviewDto from JSON
  factory EventReviewDto.fromJson(Map<String, dynamic> json) {
    return EventReviewDto(
      id: json['id'] as int,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: json['userName'] as String?,
      isApproved: json['isApproved'] as bool? ?? false,
    );
  }

  /// Converts EventReviewDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
      'isApproved': isApproved,
    };
  }

  /// Creates a copy of EventReviewDto with modified fields
  EventReviewDto copyWith({
    int? id,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? userName,
    bool? isApproved,
  }) {
    return EventReviewDto(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  @override
  String toString() {
    return 'EventReviewDto(id: $id, rating: $rating, userName: $userName, isApproved: $isApproved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventReviewDto &&
        other.id == id &&
        other.rating == rating &&
        other.userName == userName;
  }

  @override
  int get hashCode {
    return id.hashCode ^ rating.hashCode ^ userName.hashCode;
  }
}
