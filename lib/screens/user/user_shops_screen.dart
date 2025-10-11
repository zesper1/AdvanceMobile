import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/auth_provider.dart';
import 'package:panot/screens/login.dart';
import 'package:panot/widgets/logout_dialog.dart';
import '../../models/food_stall_model.dart';
import '../../providers/food_stall_provider.dart';
import '../../widgets/stalls/food_stall_card.dart';
// import '../../widgets/navbar.dart'; // No longer used
import '../../theme/app_theme.dart';
import 'favorites.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ... initState, dispose, and build methods are unchanged ...
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
    // Watch all primary async values. They all return AsyncValue<List<FoodStall>>.
    final allStallsAsync = ref.watch(foodStallProvider);
    final popularShopsAsync = ref.watch(popularShopsProvider);
    final favoriteShopsAsync = ref.watch(favoriteShopsProvider);
    final openShopsAsync = ref.watch(currentlyOpenShopsProvider);

    // Watch the user profile (already correctly handling AsyncValue)
    final userProfile = ref.watch(authNotifierProvider);
    final firstName = userProfile.when(
      data: (profile) => profile?.firstName ?? 'Guest',
      loading: () => '...',
      error: (_, __) => 'User',
    );

    // --- Start of UI/State Handling ---

    // 1. We must wait for the *base* list (allStallsAsync) to load before
    //    we can calculate categories or filter the main view.
    return allStallsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      ),
      error: (error, stack) => Scaffold(
        appBar: _buildAppBar(),
        body: Center(child: Text('Error loading data: $error')),
      ),
      data: (allStallsList) { // This is the synchronous List<FoodStall>
        // 2. Data is ready. Calculate categories using the synchronous list.
        final categories = allStallsList.map((stall) => stall.category).toSet().toList();
        categories.insert(0, 'All');

        // 3. Get the category-filtered list (which is also AsyncValue)
        final categoryShopsAsync = _selectedCategory == 'All'
            ? allStallsAsync // Pass the already resolved AsyncValue.data(allStallsList)
            : ref.watch(stallsByCategoryProvider(_selectedCategory));
            
        // Ensure the categoryShops are resolved to a synchronous list for use below.
        final categoryShopsList = categoryShopsAsync.value ?? [];


        Widget welcomeSection = Container(
          // ... (Your welcomeSection implementation, using firstName)
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.transparent, width: 0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                  children: [
                    const TextSpan(text: 'Welcome Nationalian '),
                    TextSpan(
                      text: '($firstName)',
                      style: const TextStyle(
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Here is your daily Nationalian Canteen menu...',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textColor.withOpacity(0.93),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );

        return Scaffold(
          appBar: _buildAppBar(),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: [
              welcomeSection,
              
              // 4. Wrap derived sections in their own .when() to handle loading/error
              //    state independently. If the base list (allStallsList) loaded, 
              //    these derived lists should also load quickly.
              
              // Popular Shops Section
              popularShopsAsync.when(
                loading: () => _buildSectionPlaceholder('Popular Shops'),
                error: (_, __) => const SizedBox.shrink(),
                data: (stalls) => _buildStallSection('Popular Shops', stalls, isHorizontal: true, cardType: 'vertical'),
              ),
              
              // Favorites Section
              favoriteShopsAsync.when(
                loading: () => _buildSectionPlaceholder('Favorites'),
                error: (_, __) => const SizedBox.shrink(),
                data: (stalls) => _buildStallSection('Favorites', stalls, isHorizontal: true, cardType: 'vertical'),
              ),

              // Currently Open Section
              openShopsAsync.when(
                loading: () => _buildSectionPlaceholder('Currently Open'),
                error: (_, __) => const SizedBox.shrink(),
                data: (stalls) => _buildStallSection('Currently Open', stalls, isHorizontal: false, cardType: 'horizontal'),
              ),

              // Category Section (uses the synchronous list derived earlier)
              _buildCategorySection(categories, categoryShopsList),
              
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
  Widget _buildSectionPlaceholder(String title) {
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
          ),
      );
  }
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(130),
      child: Stack(
        children: [
          AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: Opacity(
              opacity: 0.7,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/NU-D.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            title: null,
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      hintText: 'Looking for something?',
                      prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 214, 31, 31)),
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
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/NU-Dine.png',
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Favorites circular white button (unchanged)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 44,
                  height: 44,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                      child: Center(
                        child: Icon(
                          Icons.favorite_border,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),

                // MODIFIED: Profile circular white button now only prints a log
                Container(
                  margin: const EdgeInsets.only(right: 8), // Added margin for spacing
                  width: 44,
                  height: 44,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        // Per your request, this now just prints to the console
                        print('Profile button tapped!');
                      },
                      child: Center(
                        child: Icon(
                          Icons.person_outline,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),

                // ADDED: Logout circular white button with the original logout logic
                Container(
                  width: 44,
                  height: 44,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () async {
                        final didRequestLogout = await showLogoutConfirmationDialog(context);
                        if (mounted && didRequestLogout == true) {
                          try {
                            await ref.read(authNotifierProvider.notifier).signOut();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to log out: $e'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      child: Center(
                        child: Icon(
                          Icons.logout, // The original logout icon
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // ... rest of the file is unchanged ...
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
                fontSize: 14,
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
    final cardHeight = cardType == 'vertical' ? 240.0 : 160.0;

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
                    fontSize: 14,
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
                          style: const TextStyle(fontSize: 12),
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