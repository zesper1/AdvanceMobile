import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart'; // ✅ use the global AppTheme
import '../providers/shop_provider.dart';
import '../models/shop_model.dart';

class UserShopsScreen extends ConsumerWidget {
  const UserShopsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shops = ref.watch(shopProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Shops',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor, // ✅ from global AppTheme
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ShopCard(
              shopName: shop.name,
              category: shop.category,
              status: shop.status,
              rating: shop.rating,
              bestPicks: shop.bestPicks,
            ),
          );
        },
      ),
    );
  }
}

class ShopCard extends StatelessWidget {
  final String shopName;
  final String category;
  final ShopStatus status;
  final double rating;
  final List<String> bestPicks;

  const ShopCard({
    super.key,
    required this.shopName,
    required this.category,
    required this.status,
    required this.rating,
    required this.bestPicks,
  });

  Color _getStatusColor() {
    switch (status) {
      case ShopStatus.open:
        return Colors.green;
      case ShopStatus.breakTime:
        return Colors.orange;
      case ShopStatus.closed:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (status) {
      case ShopStatus.open:
        return 'Open';
      case ShopStatus.breakTime:
        return 'On Break';
      case ShopStatus.closed:
        return 'Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Shop Name + Status ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shopName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getStatusColor()),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: GoogleFonts.poppins(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // --- Category ---
            Text(
              category,
              style: GoogleFonts.poppins(
                color: AppTheme.subtleTextColor,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // --- Rating ---
            Row(
              children: [
                _buildStarRating(rating),
                const SizedBox(width: 8),
                Text(
                  rating.toString(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --- Best Picks ---
            Text(
              'Best Picks:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: bestPicks
                  .map((item) => Chip(
                        label: Text(item),
                        backgroundColor: AppTheme.cardColor,
                        labelStyle: GoogleFonts.poppins(fontSize: 12),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star, color: Colors.amber, size: 20),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.amber, size: 20),
        for (int i = 0; i < 5 - fullStars - (hasHalfStar ? 1 : 0); i++)
          const Icon(Icons.star_border, color: Colors.amber, size: 20),
      ],
    );
  }
}
