// services/shop_service.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/seller_shop_model.dart'; // Adjust path as needed
import 'package:path/path.dart' as path; // Import the path package
class ShopService {
  final _supabase = Supabase.instance.client;

  /// Fetches a list of shops owned by the currently authenticated seller.
  Future<List<SellerShop>> getSellerShops() async {
    try {
      // 1. Get the current user's ID from the session.
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) {
        throw Exception('User is not authenticated.');
      }

      // 2. Query the view to get shops matching the seller's ID.
      // We use the 'shop_with_seller_details' view to get all necessary data, including the category name.
      final response = await _supabase
          .from('food_stalls_view') // Querying the view
          .select()
          .eq('owner_id', sellerId); // Filter by the current user's ID

      // 3. Convert the JSON list into a list of SellerShop objects.
      final shops = (response as List)
          .map((shopJson) => SellerShop.fromJson(shopJson))
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
Future<int> createShop({
    required String shopName,
    required String description,
    required String imagePath, // CHANGED: from logoUrl to imagePath
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    required String categoryName,
    required List<String> subcategoryNames,
  }) async {
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) {
        throw Exception('User is not authenticated.');
      }

      // --- 1. UPLOAD IMAGE TO STORAGE ---
      final imageFile = File(imagePath);
      // Create a unique file path in the bucket using the seller's ID and the file extension.
      final fileExtension = path.extension(imagePath);
      final storagePath = '/$sellerId/logo_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      const bucket = 'shop_image';

      await _supabase.storage.from(bucket).upload(
            storagePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

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
        'p_logo_url': logoUrl, // USE THE NEW URL FROM STORAGE
        'p_opening_time': openingTimeStr,
        'p_closing_time': closingTimeStr,
        'p_category_name': categoryName,
        'p_subcategory_names': subcategoryNames,
      };

      final newShopId = await _supabase.rpc(
        'create_shop_with_subcategories',
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
}