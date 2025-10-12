import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/seller_shop_provider.dart';
import '../../models/food_stall_model.dart';
import '../../theme/app_theme.dart';
import '../../screens/user/menu_screen.dart';
import 'package:panot/services/shop_services.dart';
import 'package:panot/models/shop_review_model.dart';

class FoodStallCard extends ConsumerWidget {
  final FoodStall stall;
  final String cardType; // 'horizontal' or 'vertical'
  final bool showFavoriteButton;

  // ✅ 2. Changed to be nullable. It's no longer required.
  final Set<int>? favoriteIds;

  const FoodStallCard({
    super.key,
    required this.stall,
    this.cardType = 'horizontal',
    this.showFavoriteButton = true,
    this.favoriteIds, // Now an optional parameter
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ 3. Determine the live favorite status here, at the top level.
    // If favoriteIds is provided (user is logged in), use it.
    // Otherwise, fall back to the initial data from the `stall` model.
    final bool isCurrentlyFavorite =
        favoriteIds?.contains(stall.id) ?? stall.isFavorite;

    return GestureDetector(
      onTap: () {
        _navigateToMenuScreen(context);
      },
      // ✅ 4. Pass the calculated `isCurrentlyFavorite` status down to the builders.
      child: _buildCardContent(context, ref, isCurrentlyFavorite),
    );
  }

  // Helper methods now accept `isCurrentlyFavorite` to avoid re-calculating it.
  Widget _buildCardContent(
      BuildContext context, WidgetRef ref, bool isCurrentlyFavorite) {
    if (cardType == 'vertical') {
      return _buildVerticalCard(context, ref, isCurrentlyFavorite);
    } else {
      return _buildHorizontalCard(context, ref, isCurrentlyFavorite);
    }
  }

  void _navigateToMenuScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StallMenuScreen(stall: stall),
      ),
    );
  }

  Future<void> _showFavoriteSuccessDialog(
      BuildContext context, WidgetRef ref, bool isCurrentlyFavorite) async {
    ref
        .read(shopServiceProvider)
        .toggleFavoriteStatus(stall.id, isCurrentlyFavorite);

    // The rest of your dialog logic is great and remains the same.
    // It correctly only shows the dialog when adding a favorite.
    if (!isCurrentlyFavorite) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        pageBuilder: (ctx, a1, a2) {
          return Container(); // Empty container
        },
        transitionBuilder: (context, a1, a2, child) {
          return FadeTransition(
            opacity: a1,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(a1),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                content: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                              size: 80,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Successfully Added to Favorites!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  // --- Card Layout Builders ---
  // Pass `isCurrentlyFavorite` down to any widget that needs it.

  Widget _buildVerticalCard(
      BuildContext context, WidgetRef ref, bool isCurrentlyFavorite) {
    return Container(
      // ... (decoration is unchanged)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  stall.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: AppTheme.cardColor,
                    child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40)),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: _AvailabilityLabel(status: stall.availability),
              ),
              if (showFavoriteButton)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildFavoriteButton(
                      context, ref, isCurrentlyFavorite), // Pass status
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stall.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _buildDetailRow(
                  Icons.access_time_filled,
                  '${stall.openingTime} - ${stall.closingTime}',
                ),
                const SizedBox(height: 2),
                _buildDetailRow(Icons.category, stall.category),
                const SizedBox(height: 6),
                _buildRatingBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCard(
      BuildContext context, WidgetRef ref, bool isCurrentlyFavorite) {
    return Container(
      // ... (decoration is unchanged)
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageWithOverlays(),
          Expanded(
            child: _buildCardDetails(
                context, ref, isCurrentlyFavorite), // Pass status
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithOverlays() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              stall.imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 80,
                width: 80,
                color: AppTheme.cardColor,
                child: const Center(
                    child: Icon(Icons.image_not_supported, size: 24)),
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: _AvailabilityLabel(status: stall.availability),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails(
      BuildContext context, WidgetRef ref, bool isCurrentlyFavorite) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stall.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showFavoriteButton)
                _buildFavoriteButton(
                    context, ref, isCurrentlyFavorite), // Pass status
            ],
          ),
          const SizedBox(height: 4),
          _buildDetailRow(
            Icons.access_time_filled,
            '${stall.openingTime} - ${stall.closingTime}',
          ),
          const SizedBox(height: 2),
          _buildDetailRow(Icons.category, stall.category),
          const SizedBox(height: 4),
          _buildRatingBar(),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(
      BuildContext context, WidgetRef ref, bool isCurrentlyFavorite) {
    return GestureDetector(
      onTap: () async {
        await _showFavoriteSuccessDialog(context, ref, isCurrentlyFavorite);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          // ✅ 6. Use the live status to determine the icon's appearance.
          isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border,
          color:
              isCurrentlyFavorite ? Colors.redAccent : AppTheme.subtleTextColor,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppTheme.subtleTextColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.subtleTextColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar() {
    return FutureBuilder<List<ShopReview>>(
      future: ShopService().fetchReviewsForShop(stall.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 6),
              const Text(
                'Loading...',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Row(
            children: [
              Icon(Icons.star_border_rounded,
                  color: AppTheme.accentColor, size: 14),
              const SizedBox(width: 4),
              const Text(
                'No ratings yet',
                style: TextStyle(fontSize: 11, color: AppTheme.subtleTextColor),
              ),
            ],
          );
        }

        final reviews = snapshot.data!;
        final averageRating =
            reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length;

        return Row(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            ...List.generate(5, (index) {
              return Icon(
                index < averageRating.floor()
                    ? Icons.star_rounded
                    : index < averageRating
                        ? Icons.star_half_rounded
                        : Icons.star_border_rounded,
                color: AppTheme.accentColor,
                size: 14,
              );
            }),
          ],
        );
      },
    );
  }
}

class _AvailabilityLabel extends StatelessWidget {
  final AvailabilityStatus status;
  const _AvailabilityLabel({required this.status});

  String get _text {
    switch (status) {
      case AvailabilityStatus.Open:
        return 'Open';
      case AvailabilityStatus.Closed:
        return 'Closed';
      case AvailabilityStatus.OnBreak:
        return 'On Break';
    }
  }

  Color get _color {
    switch (status) {
      case AvailabilityStatus.Open:
        return Colors.green.shade600;
      case AvailabilityStatus.Closed:
        return Colors.red.shade600;
      case AvailabilityStatus.OnBreak:
        return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _text,
        style: const TextStyle(
            color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}
