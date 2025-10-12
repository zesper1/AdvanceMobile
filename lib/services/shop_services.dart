import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panot/models/food_stall_model.dart';
import 'package:panot/models/shop_subcategory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../models/seller_shop_model.dart';

class ShopService {
  final _supabase = Supabase.instance.client;
  final String _favoritesTable = 'user_favorite_shops'; 

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
  // lib/services/shop_services.dart

  /// Updates an existing shop, handles optional image replacement, and syncs subcategories.
  Future<void> updateShop({
    required String shopId,
    required String shopName,
    required String description,
    XFile? newImageFile,        // The new image file, if one was selected
    String? existingImageUrl,  // The URL of the current image, for cleanup
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    required int categoryId,
    required List<int> subcategoryIds,
  }) async {
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) {
        throw Exception('User is not authenticated.');
      }

      // ✅ 1. Assume the URL won't change by default
      String? imageUrlForUpdate = existingImageUrl;
      const bucket = 'shop_image';

      // ✅ 2. Only run this block if a new image was actually provided
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
        
        // B) Overwrite the URL variable with the new URL
        imageUrlForUpdate = _supabase.storage.from(bucket).getPublicUrl(newStoragePath);

        // C) Clean up the old image from storage to save space
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          final oldPath = _getStoragePathFromUrl(existingImageUrl);
          if (oldPath != null) {
            await _supabase.storage.from(bucket).remove([oldPath]);
          }
        }
      }

      // --- 3. PREPARE PARAMETERS FOR THE RPC CALL ---
      final openingTimeStr = '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}:00';
      final closingTimeStr = '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}:00';

      final params = {
        'p_shop_id': int.parse(shopId),
        'p_name': shopName,
        'p_description': description,
        'p_image_url': imageUrlForUpdate, // ✅ 4. Use the final URL (either new or old)
        'p_opening_time': openingTimeStr,
        'p_closing_time': closingTimeStr,
        'p_category_id': categoryId,
        'p_subcategory_ids': subcategoryIds,
      };

      // --- 5. EXECUTE THE RPC ---
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
  
  Future<void> updateShopDetails({
    required int shopId,
    required String shopName,
    required String description,
    required int categoryId,
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
  }) async {
    // Format TimeOfDay to 'HH:MM:SS' string format for PostgreSQL TIME WITHOUT TIME ZONE
    // TimeOfDay hour and minute are 0-padded to 2 digits.
    String formatTimeOfDayToPostgres(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      
      // The database requires a full time string; seconds are set to 00.
      return '$hour:$minute:00'; 
    }

    final openingTimeString = formatTimeOfDayToPostgres(openingTime);
    final closingTimeString = formatTimeOfDayToPostgres(closingTime);

    try {
      // Execute the update query.
      // We also update 'updated_at' to now(), which is a common practice 
      // but should be handled by a database trigger if possible. 
      // However, we include it here for an immediate update.
      await _supabase
          .from('shops')
          .update({
            'shop_name': shopName,
            'description': description,
            'category_id': categoryId,
            'opening_time': openingTimeString,
            'closing_time': closingTimeString,
            // You can optionally add 'updated_at': DateTime.now().toIso8601String(), 
            // but a database trigger is more reliable.
          })
          .eq('shop_id', shopId).select(); // Ensure the query is executed
              
      } catch (e) {
      // Log the error and re-throw a more user-friendly error
      debugPrint('Error updating shop details: $e');
      throw Exception('Failed to update shop details. Please try again.');
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
  /// Fetches a list of subcategory names for a specific shop.
  // MODIFIED: This function now returns the correct model type.
  Future<List<ShopSubcategory>> getShopSubcategories(int shopId) async {
    try {
      final response = await _supabase.rpc(
        'get_shop_subcategories',
        params: {'p_shop_id': shopId},
      );
      
      // Map the raw list of JSON objects into a list of ShopSubcategory models.
      return (response as List)
          .map((json) => ShopSubcategory.fromJson(json as Map<String, dynamic>))
          .toList();
          
    } catch (e) {
      print('Error fetching shop subcategories: $e');
      rethrow;
    }
  }

  Future<List<FoodStall>> fetchAllStalls() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from('food_stalls_view')
          .select()
          // ✅ Add this line to filter for approved shops at the database level.
          .eq('status', 'approved') 
          .order('rating', ascending: false);

      return response.map((map) => FoodStall.fromMap(map)).toList();

    } catch (e) {
      print('Error fetching stalls from view: $e');
      return [];
    }
  }

  Stream<List<int>> getFavoriteShopIdsStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      // If the user is not logged in, return an empty stream.
      return Stream.value([]);
    }

    return _supabase
        .from(_favoritesTable)
        // 1. IMPORTANT: Define the composite primary key for the stream to work.
        .stream(primaryKey: ['user_id', 'shop_id'])
        // 2. Filter the stream to only get updates for the current user.
        .eq('user_id', userId)
        .map((listOfMaps) {
          // 3. Transform the raw data (List<Map<String, dynamic>>)
          //    into a simple list of shop IDs (List<int>).
          return listOfMaps.map((map) => map['shop_id'] as int).toList();
        });
  }

  Future<void> toggleFavoriteStatus(int stallId, bool isFavorite) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      // Handle the case where the user is not logged in (e.g., show a toast/login prompt)
      throw Exception('User must be logged in to modify favorites.');
    }

    try {
      if (isFavorite) {
        await _supabase
            .from(_favoritesTable)
            .delete()
            .eq('user_id', userId) // Filter by the user's UUID
            .eq('shop_id', stallId); // Filter by the shop ID

        print('DB Action: Stall $stallId unfavorited successfully.');
      } else {
        // 💖 FAVORITE: INSERT a new entry into the junction table
        await _supabase.from(_favoritesTable).insert({
          'user_id': userId,
          'shop_id': stallId,
        });

        print('DB Action: Stall $stallId favorited successfully.');
      }
    } on PostgrestException catch (e) {
      // Supabase errors (e.g., RLS violation, network error, unique key violation)
      print('Supabase Error toggling favorite: ${e.message}');
      rethrow;
    } catch (e) {
      // General errors
      print('Error toggling favorite status: $e');
      rethrow;
    }
  }

  Future<List<FoodStall>> fetchAllStallsWithFavoriteStatus() async {
    final userId = _supabase.auth.currentUser?.id;

    try {
      // 1. Call your existing Postgres function using .rpc()
      final List<dynamic> data = await _supabase.rpc(
        // 🚨 Using your existing function name
        'get_food_stalls', 
        params: {
          // 2. Pass the user's ID to the function as 'p_user_id'
          'p_user_id': userId,
        },
      );
      print('Fetched ${data}');
      // 3. Map the results, which now include the 'is_favorite' boolean,
      //    directly to your FoodStall model.
      return data
          .map((map) => FoodStall.fromMap(map as Map<String, dynamic>))
          .toList();
          
    } catch (e) {
      print('Error fetching food stalls via RPC: $e');
      // Log the error and return an empty list or handle the error appropriately
      return [];
    }
  }
}

