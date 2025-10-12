// lib/widgets/stalls/rate_stall_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_stall_model.dart';
import '../../providers/food_stall_provider.dart';
import '../../theme/app_theme.dart';

class RateStallDialog extends ConsumerStatefulWidget {
  final FoodStall stall;

  const RateStallDialog({super.key, required this.stall});

  @override
  ConsumerState<RateStallDialog> createState() => _RateStallDialogState();
}

class _RateStallDialogState extends ConsumerState<RateStallDialog> {
  int _rating = 0; // Stores the selected star rating from 1 to 5
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Widget _buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          _rating = index + 1;
        });
      },
      icon: Icon(
        index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
        color: Colors.amber,
        size: 38,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          'Rate "${widget.stall.name}"',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'How was your experience?',
                style: TextStyle(fontSize: 14, color: AppTheme.subtleTextColor),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => _buildStar(index)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Leave a Review (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reviewController,
              maxLines: 4,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Share your feedback here...',
                hintStyle: const TextStyle(color: AppTheme.subtleTextColor),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL',
              style: TextStyle(color: AppTheme.subtleTextColor)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_rating > 0) {
              // Use ref to call the provider's method to submit the review
              ref.read(foodStallProvider.notifier).submitStallReview(
                    stallId: widget.stall.id,
                    rating: _rating.toDouble(),
                    review: _reviewController.text,
                  );
              Navigator.of(context).pop();

              // Show a confirmation message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a star rating to submit.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('SUBMIT'),
        ),
      ],
    );
  }
}
