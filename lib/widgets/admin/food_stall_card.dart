// widgets/admin/admin_food_stall_card.dart
import 'package:flutter/material.dart';
import '../../models/food_stall_model.dart';
import '../../theme/app_theme.dart';

class AdminFoodStallCard extends StatelessWidget {
  final FoodStall stall;
  final String cardType; // 'horizontal' or 'grid'

  const AdminFoodStallCard({
    super.key,
    required this.stall,
    this.cardType = 'horizontal',
  });

  @override
  Widget build(BuildContext context) {
    if (cardType == 'grid') {
      return _buildGridCard(context);
    } else {
      return _buildHorizontalCard(context);
    }
  }

  Widget _buildGridCard(BuildContext context) {
    return Container(
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
          // Image section
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
                      child: Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: _AvailabilityLabel(status: stall.availability),
              ),
            ],
          ),
          // Details section
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

  Widget _buildHorizontalCard(BuildContext context) {
    return Container(
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
          _buildImageWithOverlays(context),
          Expanded(
            child: _buildCardDetails(context),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithOverlays(BuildContext context) {
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
                  child: Icon(Icons.image_not_supported, size: 24),
                ),
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

  Widget _buildCardDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stall.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppTheme.subtleTextColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.subtleTextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar() {
    return Row(
      children: [
        Text(
          stall.rating.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          return Icon(
            index < stall.rating.floor()
                ? Icons.star_rounded
                : index < stall.rating
                    ? Icons.star_half_rounded
                    : Icons.star_border_rounded,
            color: AppTheme.accentColor,
            size: 14,
          );
        }),
      ],
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
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
