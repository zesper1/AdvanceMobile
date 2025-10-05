// screens/seller/seller_account_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SellerAccountScreen extends StatelessWidget {
  final String sellerId;

  const SellerAccountScreen({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: AppTheme.subtleTextColor),
            SizedBox(height: 16),
            Text(
              'Seller Account',
              style: TextStyle(
                color: AppTheme.subtleTextColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}