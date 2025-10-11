// lib/models/shop_subcategory_model.dart
class ShopSubcategory {
  final int id;
  final String name;
  ShopSubcategory({required this.id, required this.name});

  factory ShopSubcategory.fromJson(Map<String, dynamic> json) {
    return ShopSubcategory(
      id: json['subcategory_id'],
      name: json['subcategory_name'],
    );
  }
}