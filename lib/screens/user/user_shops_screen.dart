import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_stall_model.dart';
import '../../providers/food_stall_provider.dart';
import '../../widgets/stalls/food_stall_card.dart';
import '../../widgets/navbar.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.text = 'Looking for something?';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allStalls = ref.watch(foodStallProvider);
    final popularShops = ref.watch(popularShopsProvider);
    final favoriteShops = ref.watch(favoriteShopsProvider);
    final openShops = ref.watch(currentlyOpenShopsProvider);
    
    final categoryShops = _selectedCategory == 'All' 
        ? allStalls 
        : ref.watch(stallsByCategoryProvider(_selectedCategory));

    final categories = allStalls.map((stall) => stall.category).toSet().toList();
    categories.insert(0, 'All');

    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildStallSection('Popular Shops', popularShops, isHorizontal: true, cardType: 'vertical'),
          _buildStallSection('Favorites', favoriteShops, isHorizontal: true, cardType: 'vertical'),
          _buildStallSection('Currently Open', openShops, isHorizontal: false, cardType: 'horizontal'),
          _buildCategorySection(categories, categoryShops),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(initialIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.accentColor,
      elevation: 0,
      centerTitle: true,
      title: Container(
        height: 80,
        margin: const EdgeInsets.only(top: 16), // Add margin to the top
        child: Image.asset(
          'assets/NU-Dine.png', // Use your actual logo asset
          height: 80,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'Looking for something?',
                prefixIcon: Icon(Icons.search, color: AppTheme.subtleTextColor),
              ),
              onTap: () {
                if (_searchController.text == 'Looking for something?') {
                  setState(() {
                    _searchController.clear();
                  });
                }
              },
              onChanged: (value) {
                ref.read(foodStallProvider.notifier).searchStalls(value);
              },
              onSubmitted: (value) {
                ref.read(foodStallProvider.notifier).searchStalls(value);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStallSection(String title, List<FoodStall> stalls, {required bool isHorizontal, required String cardType}) {
    if (stalls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          isHorizontal 
            ? _buildHorizontalStallList(stalls, cardType: cardType)
            : _buildVerticalStallList(stalls, cardType: cardType),
        ],
      ),
    );
  }

 Widget _buildHorizontalStallList(List<FoodStall> stalls, {required String cardType}) {
final screenWidth = MediaQuery.of(context).size.width;
 final cardWidth = cardType == 'vertical' ? screenWidth * 0.65 : screenWidth * 0.75;
// INCREASE THIS VALUE: 200.0 -> 240.0
 final cardHeight = cardType == 'vertical' ? 240.0 : 160.0; // SAFE HEIGHT INCREASED

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 8),
        scrollDirection: Axis.horizontal,
        itemCount: stalls.length,
        itemBuilder: (context, index) {
          return Container(
            width: cardWidth,
            margin: const EdgeInsets.only(right: 8),
            child: FoodStallCard(
              stall: stalls[index],
              cardType: cardType,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalStallList(List<FoodStall> stalls, {required String cardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: stalls.map((stall) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FoodStallCard(
            stall: stall,
            cardType: cardType,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCategorySection(List<String> categories, List<FoodStall> stalls) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'By Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.subtleTextColor.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textColor),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildVerticalStallList(stalls, cardType: 'horizontal'),
        ],
      ),
    );
  }
}