import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/models/admin_view_model.dart';
import 'package:panot/models/seller_shop_model.dart' as s;
import 'package:panot/providers/admin_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// This is a common pattern to get the Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

// 1. The Service Class
class AdminService {
  final SupabaseClient _supabase;
  AdminService(this._supabase);

  /// Calls the 'get_admin_dashboard_analytics' RPC in the database.
  ///
  /// Returns a Map containing all the calculated analytics data.
  Future<Map<String, dynamic>> fetchDashboardAnalytics() async {
    try {
      // The .rpc() method calls the database function by its name
      final response = await _supabase.rpc('get_admin_dashboard_analytics');
      
      // The Supabase client automatically converts the JSONB response to a Map
      return response as Map<String, dynamic>;

    } on PostgrestException catch (e) {
      // Handle specific database errors
      print('Database Error fetching analytics: ${e.message}');
      rethrow;
    } catch (e) {
      // Handle any other unexpected errors
      print('An unexpected error occurred fetching analytics: $e');
      rethrow;
    }
  }
    Future<void> updateShopStatus({
    required String shopId,
    required ShopStatus status,
  }) async {
    try {
      // The database 'shop_status' enum uses lowercase values ('pending', 'approved').
      // We convert the Dart enum's name to the required format.
      final statusString = status.name.toLowerCase();

      await _supabase
          .from('shops')
          .update({'status': statusString})
          .eq('shop_id', int.parse(shopId)); // The primary key is 'shop_id'

    } on PostgrestException catch (e) {
      print('Database Error updating shop status: ${e.message}');
      rethrow;
    } catch (e) {
      print('An unexpected error occurred while updating shop status: $e');
      rethrow;
    }
  }

// In your admin_services.dart

  Future<List<AdminShopView>> fetchAllShopsDetailed() async {
    try {
      final response = await _supabase
        .from('admin_shops_view')
        .select();

      // Use the fromJson factory to convert each map in the list into your model
      final shops = response
          .map((json) => AdminShopView.fromJson(json))
          .toList();
          
      return shops;

    } catch (e) {
      print('Error fetching detailed shops: $e');
      rethrow;
    }
  }
}

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(ref.watch(supabaseClientProvider));
});

final allShopsAdminProvider = FutureProvider.autoDispose<List<AdminShopView>>((ref) {
  return ref.watch(adminServiceProvider).fetchAllShopsDetailed();
});

final dashboardAnalyticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(adminServiceProvider).fetchDashboardAnalytics();
});

final adminPendingShopsProvider = Provider.autoDispose<AsyncValue<List<AdminShopView>>>((ref) {
  // Watch the main admin provider
  final allShopsAsync = ref.watch(adminNotifierProvider);
  
  // Use .whenData to safely filter the list when it's available
  return allShopsAsync.whenData(
    (shops) => shops.where((shop) => shop.status == ShopStatus.pending).toList(),
  );
});