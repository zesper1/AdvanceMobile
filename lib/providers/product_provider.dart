import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:collection'; // For SplayTreeMap
import '../models/product_model.dart'; // Assuming MenuItem is now Product
import '../services/product_services.dart';

final productServiceProvider = Provider((ref) => ProductService());

class ProductNotifier extends AutoDisposeFamilyAsyncNotifier<List<Product>, int> {
  
  @override
  Future<List<Product>> build(int shopId) async {
    return ref.read(productServiceProvider).getProductsForShop(shopId);
  }

  Future<void> _refetchProducts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
  void searchProducts(String query) {
    state.whenData((products) {
      if (query.isEmpty) {
        _refetchProducts();
        return;
      }
      
      final lowerCaseQuery = query.toLowerCase();
      final filteredProducts = products.where((product) {
        return product.productName.toLowerCase().contains(lowerCaseQuery) ||
               (product.description?.toLowerCase().contains(lowerCaseQuery) ?? false);
      }).toList();
      
      state = AsyncValue.data(filteredProducts);
    });
  }
  
  Future<void> updateQuantity({
    required int productId, 
    required int newQuantity
  }) async {
    await ref.read(productServiceProvider).updateProductQuantity(productId, newQuantity);
    await _refetchProducts();
  }

  void updateLocalProduct(int productId, Product updatedProduct) {
    state.whenData((products) {
      final updatedProductsList = [
        for (final product in products)
          if (product.productId == productId) updatedProduct else product,
      ];
      state = AsyncValue.data(updatedProductsList);
    });
  }

  void addLocalProduct(Product newProduct) {
    state.whenData((products) {
      state = AsyncValue.data([...products, newProduct]);
    });
  }

  void deleteLocalProduct(int productId) {
    state.whenData((products) {
      state = AsyncValue.data(products.where((product) => product.productId != productId).toList());
    });
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required int quantity,
    required XFile imageFile,
    String? description,
    int? subcategoryId,
  }) async {
    await ref.read(productServiceProvider).createProduct(
          shopId: arg, // 'arg' is the shopId from the provider's family
          name: name,
          price: price,
          quantity: quantity,
          description: description,
          imageFile: imageFile,
          subcategoryId: subcategoryId,
        );
    await _refetchProducts(); 
  }

  Future<void> updateProduct({
    required int productId,
    required String name,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? description,
    XFile? newImageFile,
    String? existingImageUrl,
    int? subcategoryId,
  }) async {
    await ref.read(productServiceProvider).updateProduct(
          productId: productId,
          shopId: arg,
          name: name,
          price: price,
          quantity: quantity,
          isAvailable: isAvailable,
          description: description,
          newImageFile: newImageFile,
          existingImageUrl: existingImageUrl,
          subcategoryId: subcategoryId,
        );
    await _refetchProducts();
  }

  /// Deletes a product and then refreshes the list.
  Future<void> deleteProduct(int productId, String? imageUrl) async {
    await ref.read(productServiceProvider).deleteProduct(productId, imageUrl);
    await _refetchProducts();
  }
}

// 3. The public provider that the UI will use.
final productProvider = AutoDisposeAsyncNotifierProvider.family<ProductNotifier, List<Product>, int>(
  () => ProductNotifier(),
);
final temporaryStockProvider = StateProvider.family<int, int>((ref, productId) {
  // Initial state is 0, which the StockItemTile checks and overrides 
  // with the product's actual quantity (item.quantity) upon first build.
  return 0; 
});
final groupedProductsProvider = 
    Provider.family<AsyncValue<Map<String, List<Product>>>, int>((ref, shopId) {
  
  final productsAsync = ref.watch(productProvider(shopId));

  return productsAsync.whenData((products) {
    final grouped = SplayTreeMap<String, List<Product>>();

    for (final product in products) {
      final categories = product.customCategories; 
      
      if (categories.isEmpty) {
        const defaultCategory = 'Miscellaneous';
        if (!grouped.containsKey(defaultCategory)) {
          grouped[defaultCategory] = [];
        }
        grouped[defaultCategory]!.add(product);
      } else {
        for (final category in categories) {
          if (!grouped.containsKey(category)) {
            grouped[category] = [];
          }
          grouped[category]!.add(product);
        }
      }
    }

    return grouped;
  });
});