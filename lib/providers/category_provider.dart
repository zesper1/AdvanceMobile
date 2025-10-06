import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart'; // Adjust import path

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final supabase = Supabase.instance.client;
  final data = await supabase.from('shop_categories').select('category_id, category_name');
  
  // Parse the raw JSON list into a list of Category objects
  return data.map((json) => Category.fromJson(json)).toList();
});

final subcategoriesProvider = FutureProvider.family<List<Subcategory>, int>((ref, categoryId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('shop_subcategories')
      .select('subcategory_id, subcategory_name')
      .eq('category_id', categoryId); // Filters by the passed-in categoryId
      
  // Parse the raw JSON list into a list of Subcategory objects
  return data.map((json) => Subcategory.fromJson(json)).toList();
});