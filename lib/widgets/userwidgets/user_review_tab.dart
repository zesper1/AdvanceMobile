// lib/widgets/stalls/user_reviews_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/models/food_stall_model.dart';
import 'package:panot/models/shop_review_model.dart';
import 'package:panot/services/shop_services.dart';
import 'package:panot/theme/app_theme.dart'; // ✅ for consistent color use

class UserReviewsTab extends ConsumerStatefulWidget {
  final FoodStall stall;
  const UserReviewsTab({super.key, required this.stall});

  @override
  ConsumerState<UserReviewsTab> createState() => _UserReviewsTabState();
}

class _UserReviewsTabState extends ConsumerState<UserReviewsTab> {
  late Future<List<ShopReview>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ShopService().fetchReviewsForShop(widget.stall.id);
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  Widget _buildOverallRating() {
    return FutureBuilder<List<ShopReview>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildNoReviews();
        }

        final reviews = snapshot.data!;
        final averageRating =
            reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length;
        final ratingCount = reviews.length;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      _buildRatingStars(averageRating.round()),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRatingBar(
                            5,
                            reviews.where((r) => r.rating == 5).length,
                            ratingCount),
                        _buildRatingBar(
                            4,
                            reviews.where((r) => r.rating == 4).length,
                            ratingCount),
                        _buildRatingBar(
                            3,
                            reviews.where((r) => r.rating == 3).length,
                            ratingCount),
                        _buildRatingBar(
                            2,
                            reviews.where((r) => r.rating == 2).length,
                            ratingCount),
                        _buildRatingBar(
                            1,
                            reviews.where((r) => r.rating == 1).length,
                            ratingCount),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Based on $ratingCount review${ratingCount == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingBar(int star, int countForStar, int totalReviews) {
    final percentage =
        totalReviews > 0 ? (countForStar / totalReviews) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$star',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.round()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReviews() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.reviews_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your experience with this stall!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    return FutureBuilder<List<ShopReview>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading reviews',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final reviews = snapshot.data!;

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _buildReviewCard(review);
          },
        );
      },
    );
  }

  Widget _buildReviewCard(ShopReview review) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRatingStars(review.rating),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getUserDisplayName(review.studentUserId),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getUserDisplayName(String userId) {
    return 'User ${userId.substring(0, 8)}...';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130), // ⬆️ Increased height
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            '${widget.stall.name} Reviews',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17, // ⬆️ Larger font size
              color: Color.fromRGBO(255, 255, 255, 1),
              letterSpacing: 0.5,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/NU-Dine.png'),
                fit: BoxFit.cover,
                alignment: Alignment.center, // centers the image nicely
              ),
            ),
            child: Container(
              // Optional dark overlay for readability
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: AppTheme.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _reviewsFuture = ShopService().fetchReviewsForShop(widget.stall.id);
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildOverallRating(),
              const SizedBox(height: 16),
              _buildReviewList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
