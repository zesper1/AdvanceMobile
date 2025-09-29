import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/auth_provider.dart';
import 'package:panot/providers/shop_provider.dart';
import 'package:panot/models/shop_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final shopsAsync = ref.watch(shopProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Greeting
          authState.when(
            data: (profile) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                profile == null
                    ? 'Welcome! Profile not found.'
                    : 'Welcome, ${profile['first_name']}!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),

          const SizedBox(height: 10),

          // 🔹 Shops list
          Expanded(
            child: shopsAsync.when(
              data: (shops) {
                if (shops.isEmpty) {
                  return const Center(child: Text("No shops available yet."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Text(
                              shop.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Description
                            if (shop.description.isNotEmpty)
                              Text(
                                shop.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),

                            const SizedBox(height: 6),

                            // Category + Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Category: ${shop.category}"),
                                Text(
                                  shop.status.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: shop.status == ShopStatus.open
                                        ? Colors.green
                                        : (shop.status == ShopStatus.closed
                                            ? Colors.red
                                            : Colors.orange),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Operating Hours
                            if (shop.operatingHours.isNotEmpty)
                              Text("🕒 Hours: ${shop.operatingHours}"),

                            const SizedBox(height: 6),

                            // Rating + Views
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(shop.rating.toStringAsFixed(1)),
                                const SizedBox(width: 16),
                                const Icon(Icons.visibility,
                                    color: Colors.blueGrey, size: 18),
                                const SizedBox(width: 4),
                                Text("${shop.views} views"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }
}
