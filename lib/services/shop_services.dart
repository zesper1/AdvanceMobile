import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../models/seller_shop_model.dart';

class ShopService {
  final _supabase = Supabase.instance.client;

  /// Creates a new shop by first uploading a logo and then calling an RPC.
  /// This method is platform-aware and handles uploads for both mobile and web.
  Future<int> createShop({
    required String shopName,
    required String description,
    required XFile imageFile, // CHANGED: Accepts the full XFile object
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    required int categoryName,
    required List<int> subcategoryNames,
  }) async {
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) {
        throw Exception('User is not authenticated.');
      }

      // --- 1. UPLOAD IMAGE TO STORAGE (Platform-Aware) ---
      // Get the file extension from the image file's name
      final fileExtension = path.extension(imageFile.name);
      final storagePath = '/$sellerId/logo_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      const bucket = 'shop_image';

      // Use a conditional check for the web platform
      if (kIsWeb) {
        // For web, we read the bytes from the XFile and use uploadBinary
        final imageBytes = await imageFile.readAsBytes();
        await _supabase.storage.from(bucket).uploadBinary(
              storagePath,
              imageBytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
      } else {
        // For mobile, we use the file path and the standard upload method
        await _supabase.storage.from(bucket).upload(
              storagePath,
              File(imageFile.path),
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
      }

      // --- 2. GET THE PUBLIC URL OF THE UPLOADED IMAGE ---
      final logoUrl = _supabase.storage.from(bucket).getPublicUrl(storagePath);

      // --- 3. CALL THE RPC WITH THE NEW LOGO URL ---
      final openingTimeStr =
          '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}:00';
      final closingTimeStr =
          '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}:00';

      final params = {
        'p_seller_id': sellerId,
        'p_shop_name': shopName,
        'p_description': description,
        'p_image_url': logoUrl,
        'p_opening_time': openingTimeStr,
        'p_closing_time': closingTimeStr,
        'p_category_id': categoryName,
        'p_subcategory_ids': subcategoryNames,
      };

      final newShopId = await _supabase.rpc(
        'create_shop_with_subcategories_by_id',
        params: params,
      );

      return newShopId as int;
    } on StorageException catch (e) {
      print('Storage Error creating shop: ${e.message}');
      rethrow;
    } on PostgrestException catch (e) {
      print('Database Error creating shop: ${e.message}');
      rethrow;
    } catch (e) {
      print('An unexpected error occurred: $e');
      rethrow;
    }
  }

  /// Fetches a list of shops owned by the currently authenticated seller.
  Future<List<SellerShop>> getSellerShops() async {
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) {
        throw Exception('User is not authenticated.');
      }

      // Call the function that returns JSON objects
      final response = await _supabase.rpc(
        'get_seller_food_stalls', // Use the JSON-returning function
        params: {'p_seller_id': sellerId},
      );

      // This part is already correct! It maps the list of JSON objects.
      final shops = (response as List)
          .map((shopJson) => SellerShop.fromJson(shopJson as Map<String, dynamic>))
          .toList();

      return shops;
    } on PostgrestException catch (e) {
      print('Database Error fetching seller shops: ${e.message}');
      rethrow;
    } catch (e) {
      print('An unexpected error occurred: $e');
      rethrow;
    }
  }
    /// Updates an existing shop, handles optional image replacement, and syncs subcategories.
  Future<void> updateShop({
    required String shopId,
    required String shopName,
    required String description,
    XFile? newImageFile,      // The new image file, if one was selected
    String? existingImageUrl, // The URL of the current image, for cleanup
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    required int categoryId,         // The ID of the main category
    required List<int> subcategoryIds, // The IDs of the selected subcategories
  }) async {
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) {
        throw Exception('User is not authenticated.');
      }

      String? imageUrlForUpdate = existingImageUrl;
      const bucket = 'shop_image';

      // --- 1. HANDLE IMAGE UPDATE (IF A NEW IMAGE IS PROVIDED) ---
      if (newImageFile != null) {
        // A) Upload the new image
        final fileExtension = path.extension(newImageFile.name);
        final newStoragePath = '/$sellerId/logo_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

        if (kIsWeb) {
          final imageBytes = await newImageFile.readAsBytes();
          await _supabase.storage.from(bucket).uploadBinary(
                newStoragePath,
                imageBytes,
                fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
              );
        } else {
          await _supabase.storage.from(bucket).upload(
                newStoragePath,
                File(newImageFile.path),
                fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
              );
        }
        
        imageUrlForUpdate = _supabase.storage.from(bucket).getPublicUrl(newStoragePath);

        // B) Clean up the old image from storage to save space
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          final oldPath = _getStoragePathFromUrl(existingImageUrl);
          if (oldPath != null) {
            await _supabase.storage.from(bucket).remove([oldPath]);
          }
        }
      }

      // --- 2. PREPARE PARAMETERS FOR THE RPC CALL ---
      final openingTimeStr = '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}:00';
      final closingTimeStr = '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}:00';

      final params = {
        'p_shop_id': int.parse(shopId),
        'p_name': shopName,
        'p_description': description,
        'p_image_url': imageUrlForUpdate, // Use the new or existing URL
        'p_opening_time': openingTimeStr,
        'p_closing_time': closingTimeStr,
        'p_category_id': categoryId,
        'p_subcategory_ids': subcategoryIds, // Pass the list of integer IDs
      };

      // --- 3. EXECUTE THE RPC ---
      await _supabase.rpc('update_shop_with_subcategories', params: params);

    } on StorageException catch (e) {
      print('Storage Error updating shop: ${e.message}');
      rethrow;
    } on PostgrestException catch (e) {
      print('Database Error updating shop: ${e.message}');
      rethrow;
    } catch (e) {
      print('An unexpected error occurred while updating shop: $e');
      rethrow;
    }
  }

  /// Helper function to extract the storage path from a public URL.
  String? _getStoragePathFromUrl(String url) {
    const bucketName = 'shop_image';
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    // Find the segment after the bucket name
    final bucketIndex = segments.indexOf(bucketName);
    if (bucketIndex != -1 && segments.length > bucketIndex + 1) {
      // Rejoin the rest of the path
      return segments.sublist(bucketIndex + 1).join('/');
    }
    return null;
  }

  /// if ON DELETE CASCADE is configured on your Postgres foreign keys.
Future<void> deleteShop(String shopId) async {
  try {
    // 1. Perform the deletion on the 'shops' table.
    // The .delete() method returns a PostgrestFilterBuilder
    // which allows you to apply the .eq() filter.
    final response = await _supabase
        .from('shops')
        .delete()
        .eq('shop_id', shopId);

    // Supabase will throw an exception on network/database errors.
    // If the request is successful, the response is generally null for DELETE.
    
    print('Shop with ID $shopId deleted successfully.');

  } on PostgrestException catch (error) {
    // Handle Supabase-specific errors (e.g., RLS policy violation)
    print('Supabase Error deleting shop: ${error.message}');
    throw Exception('Database Error: ${error.message}');
  } catch (error) {
    // Handle any other general exceptions (e.g., network issues)
    print('General Error deleting shop: $error');
    throw Exception('Failed to delete shop: $error');
  }
}
}

