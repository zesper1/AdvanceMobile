import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shop_model.dart';

class ShopService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Shop>> fetchShops() async {
    final response = await _supabase
        .from('shop_view')
        .select();

    return (response as List)
        .map((shop) => Shop.fromMap(shop as Map<String, dynamic>))
        .toList();
  }
  Future<List<Shop>> fetchShopsByOwner(String ownerId) async {
    final response = await _supabase
        .from('shop_view')
        .select()
        .eq('owner_id', ownerId);

    return (response as List)
        .map((shop) => Shop.fromMap(shop as Map<String, dynamic>))
        .toList();
  }

   /// NEW: Create a shop in DB
  Future<Shop> createShop(Map<String, dynamic> data) async {
    final response = await _supabase.from('shops').insert(data).select().single();
    return Shop.fromMap(response);
  }

}

