import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panot/models/food_stall_model.dart';
import 'package:panot/models/shop_review_model.dart';
import 'package:panot/models/shop_subcategory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

import '../models/seller_shop_model.dart';
import '../constants/database.dart';

class ShopService {
  final _supabase = Supabase.instance.client;

  /// Creates a new shop by first uploading a logo and then calling an RPC.
  /// This method is platform-aware and handles uploads for both mobile and web.
  Future<int> createShop({
    required String shopName,
    required String description,
    required XFile imageFile,
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    required int categoryName,
    required List<int> subcategoryNames,
  }) async {
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) throw Exception('User is not authenticated.');

      // --- 1. Upload image ---
      final fileExtension = path.extension(imageFile.name);
      final storagePath =
          '/$sellerId/logo_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      const bucket = 'shop_image';

      if (kIsWeb) {
        final imageBytes = await imageFile.readAsBytes();
        await _supabase.storage.from(bucket).uploadBinary(
              storagePath,
              imageBytes,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
      } else {
        await _supabase.storage.from(bucket).upload(
              storagePath,
              File(imageFile.path),
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
      }

      // --- 2. Get public URL ---
      final logoUrl = _supabase.storage.from(bucket).getPublicUrl(storagePath);

      // --- 3. Prepare RPC params ---
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
      debugPrint('Storage Error creating shop: ${e.message}');
      rethrow;
    } on PostgrestException catch (e) {
      debugPrint('Database Error creating shop: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error creating shop: $e');
      rethrow;
    }
  }

  /// Fetches a list of shops owned by the current seller.
  Future<List<SellerShop>> getSellerShops() async {
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) throw Exception('User is not authenticated.');

      final response = await _supabase.rpc(
        'get_seller_food_stalls',
        params: {'p_seller_id': sellerId},
      );

      return (response as List)
          .map((shopJson) =>
              SellerShop.fromJson(shopJson as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('Database Error fetching seller shops: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error fetching seller shops: $e');
      rethrow;
    }
  }

  /// Updates an existing shop and handles optional image replacement.
  Future<void> updateShop({
    required String shopId,
    required String shopName,
    required String description,
    XFile? newImageFile,
    String? existingImageUrl,
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    required int categoryId,
    required List<int> subcategoryIds,
  }) async {
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) throw Exception('User is not authenticated.');

      String? imageUrlForUpdate = existingImageUrl;
      const bucket = 'shop_image';

      // Upload new image if provided
      if (newImageFile != null) {
        final fileExtension = path.extension(newImageFile.name);
        final newStoragePath =
            '/$sellerId/logo_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

        if (kIsWeb) {
          final imageBytes = await newImageFile.readAsBytes();
          await _supabase.storage.from(bucket).uploadBinary(
                newStoragePath,
                imageBytes,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false),
              );
        } else {
          await _supabase.storage.from(bucket).upload(
                newStoragePath,
                File(newImageFile.path),
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false),
              );
        }

        imageUrlForUpdate =
            _supabase.storage.from(bucket).getPublicUrl(newStoragePath);

        // Delete old image if it exists
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          final oldPath = _getStoragePathFromUrl(existingImageUrl);
          if (oldPath != null) {
            await _supabase.storage.from(bucket).remove([oldPath]);
          }
        }
      }

      // Prepare params
      final openingTimeStr =
          '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}:00';
      final closingTimeStr =
          '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}:00';

      final params = {
        'p_shop_id': int.parse(shopId),
        'p_name': shopName,
        'p_description': description,
        'p_image_url': imageUrlForUpdate,
        'p_opening_time': openingTimeStr,
        'p_closing_time': closingTimeStr,
        'p_category_id': categoryId,
        'p_subcategory_ids': subcategoryIds,
      };

      await _supabase.rpc('update_shop_with_subcategories', params: params);
    } on StorageException catch (e) {
      debugPrint('Storage Error updating shop: ${e.message}');
      rethrow;
    } on PostgrestException catch (e) {
      debugPrint('Database Error updating shop: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error updating shop: $e');
      rethrow;
    }
  }

  /// Update only basic shop details
  Future<void> updateShopDetails({
    required int shopId,
    required String shopName,
    required String description,
    required int categoryId,
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
  }) async {
    String formatTime(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

    try {
      await _supabase
          .from('shops')
          .update({
            'shop_name': shopName,
            'description': description,
            'category_id': categoryId,
            'opening_time': formatTime(openingTime),
            'closing_time': formatTime(closingTime),
          })
          .eq('shop_id', shopId)
          .select();
    } catch (e) {
      debugPrint('Error updating shop details: $e');
      throw Exception('Failed to update shop details. Please try again.');
    }
  }

  /// Helper: Extracts storage path from public URL
  String? _getStoragePathFromUrl(String url) {
    const bucketName = 'shop_image';
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf(bucketName);
    if (bucketIndex != -1 && segments.length > bucketIndex + 1) {
      return segments.sublist(bucketIndex + 1).join('/');
    }
    return null;
  }

  /// Deletes a shop record from the database.
  Future<void> deleteShop(String shopId) async {
    try {
      await _supabase.from('shops').delete().eq('shop_id', shopId);
      debugPrint('Shop with ID $shopId deleted successfully.');
    } on PostgrestException catch (e) {
      debugPrint('Supabase Error deleting shop: ${e.message}');
      throw Exception('Database Error: ${e.message}');
    } catch (e) {
      debugPrint('General Error deleting shop: $e');
      throw Exception('Failed to delete shop: $e');
    }
  }

  /// Fetches subcategories for a given shop.
  Future<List<ShopSubcategory>> getShopSubcategories(int shopId) async {
    try {
      final response = await _supabase.rpc(
        'get_shop_subcategories',
        params: {'p_shop_id': shopId},
      );
      return (response as List)
          .map((json) => ShopSubcategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching shop subcategories: $e');
      rethrow;
    }
  }

  /// Fetch all approved stalls
  Future<List<FoodStall>> fetchAllStalls() async {
    try {
      final response = await _supabase
          .from('food_stalls_view')
          .select()
          .eq('status', 'approved')
          .order('rating', ascending: false);
      return (response as List)
          .map((map) => FoodStall.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching stalls: $e');
      return [];
    }
  }

  /// Stream user's favorite shop IDs
  Stream<List<int>> getFavoriteShopIdsStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from(userFavoritesTable)
        .stream(primaryKey: ['user_id', 'shop_id'])
        .eq('user_id', userId)
        .map((list) => list.map((map) => map['shop_id'] as int).toList());
  }

  /// Toggle favorite shop
  Future<void> toggleFavoriteStatus(int stallId, bool isFavorite) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User must be logged in.');

    try {
      if (isFavorite) {
        await _supabase
            .from(userFavoritesTable)
            .delete()
            .eq('user_id', userId)
            .eq('shop_id', stallId);
        debugPrint('Unfavorited shop $stallId.');
      } else {
        await _supabase.from(userFavoritesTable).insert({
          'user_id': userId,
          'shop_id': stallId,
        });
        debugPrint('Favorited shop $stallId.');
      }
    } on PostgrestException catch (e) {
      debugPrint('Supabase Error toggling favorite: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  /// Fetch all food stalls with favorite status
  Future<List<FoodStall>> fetchAllStallsWithFavoriteStatus() async {
    final userId = _supabase.auth.currentUser?.id;
    try {
      final data = await _supabase.rpc(
        'get_food_stalls',
        params: {'p_user_id': userId},
      );

      return (data as List)
          .map((map) => FoodStall.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching food stalls via RPC: $e');
      return [];
    }
  }

  /// Submit a new shop review
  Future<void> submitReview({
    required int shopId,
    required int rating,
    String? comment,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated.');

    try {
      await _supabase.from(shopReviewsTable).insert({
        'shop_id': shopId,
        'student_user_id': userId,
        'rating': rating,
        'comment': comment,
      });
    } on PostgrestException catch (e) {
      debugPrint('Database error submitting review: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error submitting review: $e');
      rethrow;
    }
  }

  /// Fetch all reviews for a shop
  Future<List<ShopReview>> fetchReviewsForShop(int shopId) async {
    try {
      final response = await _supabase
          .from(shopReviewsTable)
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((map) => ShopReview.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reviews for shop $shopId: $e');
      return [];
    }
  }
}
