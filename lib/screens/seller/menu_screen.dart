// screens/seller/seller_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_stall_model.dart';
import '../../widgets/seller_navbar.dart';
import '../seller/manage_items.dart';
import '../seller/manage_stock.dart';

class SellerMainScreen extends ConsumerStatefulWidget {
  final FoodStall stall;

  const SellerMainScreen({super.key, required this.stall});

  @override
  ConsumerState<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends ConsumerState<SellerMainScreen> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? SellerMenuScreen(stall: widget.stall)
          : ManageStoreScreen(stall: widget.stall),
      bottomNavigationBar: SellerBottomNavBar(
        initialIndex: _currentIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}
