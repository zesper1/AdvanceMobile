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
    required String categoryName,
    required List<String> subcategoryNames,
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
        'p_logo_url': logoUrl,
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

  /// Fetches a list of shops owned by the currently authenticated seller.
  Future<List<SellerShop>> getSellerShops() async {
    try {
      final sellerId = _supabase.auth.currentUser?.id;
      if (sellerId == null) {
        throw Exception('User is not authenticated.');
      }

      final response = await _supabase.
      rpc('get_food_stalls',
          params:{
            'p_user_id': sellerId
      });

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
}

