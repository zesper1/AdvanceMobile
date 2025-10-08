// widgets/seller_navbar.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SellerBottomNavBar extends StatefulWidget { // Changed from SellerNavBar to SellerBottomNavBar
  final int initialIndex;
  final Function(int) onTabChanged;

  const SellerBottomNavBar({ // Changed constructor name
    super.key,
    this.initialIndex = 0,
    required this.onTabChanged,
  });

  @override
  State<SellerBottomNavBar> createState() => _SellerBottomNavBarState();
}

class _SellerBottomNavBarState extends State<SellerBottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onTabChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.subtleTextColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pending Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Account',
          ),
        ],
      ),
    );
  }
}