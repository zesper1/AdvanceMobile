// lib/services/product_services.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panot/models/shop_subcategory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../models/product_model.dart'; // We'll create this model next

class ProductService {
  final _supabase = Supabase.instance.client;

  /// Fetches all products for a specific shop.
  // In your product_services.dart...

  Future<List<Product>> getProductsForShop(int shopId) async {
    try {
      // Query the view instead of the table
      final response = await _supabase
        .from('products_view') // <-- Use the view name here
        .select()
        .eq('shop_id', shopId)
        .order('product_name', ascending: true);
        
      // Your Product.fromJson model will need a 'subcategory_name' field
      return response.map((json) => Product.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print('Database Error fetching products: ${e.message}');
      rethrow;
    }
  }

  /// Creates a new product, including image upload.
  Future<void> createProduct({
    required int shopId,
    required String name,
    required double price,
    required int quantity,
    required XFile imageFile,
    String? description,
    int? subcategoryId, // <-- ADD THIS
  }) async {
    try {
      // 1. Upload the image first
      final imageUrl = await _uploadProductImage(shopId: shopId, imageFile: imageFile);

      // 2. Insert the product data with the image URL and subcategory ID
      await _supabase.from('products').insert({
        'shop_id': shopId,
        'product_name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'image_url': imageUrl,
        'subcategory_id': subcategoryId, // <-- AND INCLUDE IT HERE
      });
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  /// Updates an existing product, with optional new image handling.
   /// Updates an existing product, with optional new image and subcategory.
  Future<void> updateProduct({
    required int productId,
    required int shopId,
    required String name,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? description,
    XFile? newImageFile,
    String? existingImageUrl,
    int? subcategoryId, // <-- ADD THIS
  }) async {
    try {
      String? imageUrlForUpdate = existingImageUrl;

      if (newImageFile != null) {
        imageUrlForUpdate = await _uploadProductImage(shopId: shopId, imageFile: newImageFile);
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          await _deleteProductImage(existingImageUrl);
        }
      }

      await _supabase.from('products').update({
        'product_name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'is_available': isAvailable,
        'image_url': imageUrlForUpdate,
        'subcategory_id': subcategoryId, // <-- AND INCLUDE IT HERE
      }).eq('product_id', productId);

    } on StorageException catch (e) {
      print('Storage Error updating product: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating product: $e');
      rethrow;}
  }

  // In lib/services/product_services.dart

  /// Deletes a product from the database and its image from storage.
  Future<void> deleteProduct(int productId, String? imageUrl) async {
    try {
      // 1. Delete the product record from the 'products' table first.
      await _supabase.from('products').delete().eq('product_id', productId);

      // 2. If the database deletion was successful, delete the associated image.
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _deleteProductImage(imageUrl);
      }
    } on PostgrestException catch (e) {
      print('Database Error deleting product: ${e.message}');
      rethrow;
    } catch (e) {
      print('An unexpected error occurred while deleting product: $e');
      rethrow;
    }
  }

  // --- PRIVATE HELPER FOR DELETING IMAGE ---
  // This helper extracts the path from a URL and removes the file from storage.
  Future<void> _deleteProductImage(String imageUrl) async {
    const bucket = 'product_images'; // Make sure this matches your bucket name
    try {
      final uri = Uri.parse(imageUrl);
      // The path is everything after the bucket name in the URL segments
      // e.g., /storage/v1/object/public/product_images/123/product_abc.png
      final pathIndex = uri.pathSegments.indexOf(bucket);
      if (pathIndex != -1 && uri.pathSegments.length > pathIndex + 1) {
        final imagePath = uri.pathSegments.sublist(pathIndex + 1).join('/');
        await _supabase.storage.from(bucket).remove([imagePath]);
      }
    } catch (e) {
      // We print the error but don't rethrow it, as the main record was already deleted.
      print('Error deleting old image from storage, but product was deleted from DB: $e');
    }
  }

  // --- PRIVATE HELPER METHODS FOR IMAGE HANDLING ---

  Future<String> _uploadProductImage({required int shopId, required XFile imageFile}) async {
    const bucket = 'product_images'; // Use a dedicated bucket for products
    final fileExtension = path.extension(imageFile.name);
    final storagePath = '/$shopId/product_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

    if (kIsWeb) {
      final imageBytes = await imageFile.readAsBytes();
      await _supabase.storage.from(bucket).uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
    } else {
      await _supabase.storage.from(bucket).upload(
            storagePath,
            File(imageFile.path),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
    }
    return _supabase.storage.from(bucket).getPublicUrl(storagePath);
  }

  // MODIFIED: This now returns a typed list
  Future<List<ShopSubcategory>> getShopSubcategories(int shopId) async {
    try {
      final response = await _supabase.rpc(
        'get_shop_subcategories',
        params: {'p_shop_id': shopId},
      );
      return (response as List)
          .map((json) => ShopSubcategory.fromJson(json))
          .toList();
    } catch (e) {
    print('Error fetching shop subcategories: $e');
    rethrow;
    }
  }

  Future<void> updateProductQuantity(int productId, int newQuantity) async {
    try {
      // Assuming 'products' is the correct table name
      await _supabase
          .from('products')
          .update({'quantity': newQuantity})
          .eq('product_id', productId)
          .select();
    } catch (e) {
      // Log the error and re-throw
      debugPrint('Error updating product quantity: $e');
      throw Exception('Failed to update product quantity on server.');
    }
  }
}