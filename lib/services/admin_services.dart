import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

// 2. The Provider for the Service
// This makes the AdminService available to the rest of your app.
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(ref.watch(supabaseClientProvider));
});

// 3. A FutureProvider to Fetch the Data for the UI
// This is the provider your widget will watch.
final dashboardAnalyticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  // It calls the fetch method from your AdminService
  return ref.watch(adminServiceProvider).fetchDashboardAnalytics();
});