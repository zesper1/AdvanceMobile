import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;

  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
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
    
    // Navigate to different screens based on index
    switch (index) {
      case 0:
        // Already on Food Stalls screen
        break;
      case 1:
        // Navigate to Favorites screen
        // Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesScreen()));
        break;
      case 2:
        // Navigate to Account screen
        // Navigator.push(context, MaterialPageRoute(builder: (_) => AccountScreen()));
        break;
    }
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
            icon: Icon(Icons.storefront),
            label: 'Food Stalls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}