import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
// Temporary hardcoded categories (map name -> ID)
final Map<String, int> categories = {
  'Beverages': 1,
  'Pastry': 2,
};

class SellerHomeScreen extends ConsumerWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

void _showCreateShopDialog(BuildContext context, WidgetRef ref) {

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final operatingHoursController = TextEditingController();
  String selectedCategory = 'Beverages';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.store, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text("Create Shop", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Shop Name",
                      prefixIcon: const Icon(Icons.storefront),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                        labelText: "Category",
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categories.keys.map((cat) {
                        return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                        );
                    }).toList(),
                    onChanged: (value) {
                        setState(() {
                        selectedCategory = value!;
                        });
                    },
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Description",
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          operatingHoursController.text = picked.format(context);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: operatingHoursController,
                        decoration: InputDecoration(
                          labelText: "Operating Hours",
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppTheme.primaryColor,
                ),
                icon: const Icon(Icons.check),
                label: const Text("Create"),
                onPressed: () async {
                  final auth = ref.read(authNotifierProvider.notifier);
                  final ownerId = auth.currentUserId;
                    final categoryId = categories[selectedCategory];

                    if (categoryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid category selected.")),
                    );
                    return;
                    }
                  final shopData = {
                    'shop_name': nameController.text,
                    'category_id': categoryId,
                    'description': descriptionController.text,
                    'operating_hours': operatingHoursController.text,
                    'status': 'pending',
                    'owner_id': ownerId,
                  };

                  await ref.read(shopProvider.notifier).createShop(shopData);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    },
  );
}

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seller Dashboard'),
          centerTitle: true,
          actions: [
            // 🔹 Logout button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.accentColor,
            indicatorWeight: 3.0,
            labelStyle: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            unselectedLabelStyle: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white70),
            tabs: const [
              Tab(text: 'My Shops'),
              Tab(text: 'All Shops'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 🔹 My Shops (filtered by seller ID)
            authState.when(
              data: (profile) {
                if (profile == null) {
                  return const Center(
                      child: Text("Profile not found. Please log in again."));
                }
                final auth = ref.watch(authNotifierProvider.notifier);
                final userId = auth.currentUserId;
                return ShopListView(filterBySellerId: userId);
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),

            // 🔹 All Shops (no filter)
            const ShopListView(),
          ],
        ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () => _showCreateShopDialog(context, ref),
  icon: const Icon(Icons.add, color: AppTheme.primaryColor),
  label: const Text(
    'Create Shop',
    style: TextStyle(
        color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
  ),
  backgroundColor: AppTheme.accentColor,
),

      ),
    );
  }
}

class ShopListView extends ConsumerWidget {
  final String? filterBySellerId; // 👈 NEW

  const ShopListView({super.key, this.filterBySellerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(shopProvider);

    final auth = ref.watch(authNotifierProvider.notifier);
final userId = auth.currentUserId;
    return shopsAsync.when(
      data: (shops) {
        // 🔹 Apply filter if sellerId is provided
        if (filterBySellerId != null) {
         shops = shops.where((shop) => shop.ownerId == filterBySellerId).toList();

        }

        if (shops.isEmpty) {
          return const Center(
            child: Text(
              'No shops available yet.',
              style: TextStyle(color: AppTheme.subtleTextColor, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            return ShopCard(shop: shops[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}

// A card widget to display individual shop information.
class ShopCard extends StatelessWidget {
  final Shop shop;

  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop name + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    shop.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: shop.status),
              ],
            ),
            const SizedBox(height: 4),
            // Category
            Text(
              'Category: ${shop.category}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.subtleTextColor),
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              shop.description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.subtleTextColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Operating hours
            Text(
              'Hours: ${shop.operatingHours}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.subtleTextColor),
            ),
            const SizedBox(height: 8),
            // Rating
            RatingStars(rating: shop.rating),
          ],
        ),
      ),
    );
  }
}
// A badge to visually represent the shop's status.
class StatusBadge extends StatelessWidget {
  final ShopStatus status;

  const StatusBadge({super.key, required this.status});

 Color _getStatusColor() {
  switch (status) {
    case ShopStatus.open:
      return Colors.green.shade600;
    case ShopStatus.breakTime:
      return Colors.orange.shade700;
    case ShopStatus.closed:
      return Colors.red.shade600;
    case ShopStatus.pending:
      return Colors.blueGrey.shade600; // add this line
  }
}

String _getStatusText() {
  switch (status) {
    case ShopStatus.open:
      return 'Open';
    case ShopStatus.breakTime:
      return 'Break';
    case ShopStatus.closed:
      return 'Closed';
    case ShopStatus.pending:
      return 'Pending'; // add this line
  }
}


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        _getStatusText(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// A widget to display the shop's rating using stars.
class RatingStars extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        if (index >= rating) {
          // Empty star
          return Icon(Icons.star_border,
              color: AppTheme.accentColor, size: size);
        } else if (index > rating - 1 && index < rating) {
          // Half star
          return Icon(Icons.star_half, color: AppTheme.accentColor, size: size);
        } else {
          // Full star
          return Icon(Icons.star, color: AppTheme.accentColor, size: size);
        }
      }),
    );
  }
}
