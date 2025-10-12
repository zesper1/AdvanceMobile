class ShopReview {
  /// The unique identifier for the review.
  final int reviewId;

  /// The ID of the shop this review belongs to.
  final int shopId;

  /// The UUID of the student who wrote the review.
  final String studentUserId;

  /// The rating given, from 1 to 5.
  final int rating;

  /// The optional text comment left by the user.
  final String? comment;

  /// The timestamp when the review was created.
  final DateTime createdAt;

  const ShopReview({
    required this.reviewId,
    required this.shopId,
    required this.studentUserId,
    required this.rating,
    this.comment, // Nullable, so it's not required
    required this.createdAt,
  });

  /// A factory constructor for creating a new `ShopReview` instance
  /// from a map structure, which is what Supabase returns.
  factory ShopReview.fromMap(Map<String, dynamic> map) {
    return ShopReview(
      reviewId: map['review_id'] as int,
      shopId: map['shop_id'] as int,
      studentUserId: map['student_user_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String?, // Cast as nullable String
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Creates a copy of this ShopReview but with the given fields replaced with new values.
  /// This is useful for state management (e.g., with Riverpod).
  ShopReview copyWith({
    int? reviewId,
    int? shopId,
    String? studentUserId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ShopReview(
      reviewId: reviewId ?? this.reviewId,
      shopId: shopId ?? this.shopId,
      studentUserId: studentUserId ?? this.studentUserId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}