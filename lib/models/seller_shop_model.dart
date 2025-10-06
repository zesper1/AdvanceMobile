// models/seller_shop_model.dart

enum ShopStatus { Pending, Approved, Rejected }

// Helper function to parse the enum safely
ShopStatus _parseShopStatus(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return ShopStatus.Approved;
    case 'rejected':
      return ShopStatus.Rejected;
    default:
      return ShopStatus.Pending;
  }
}

class SellerShop {
  final String id;
  final String name;
  final String? imageUrl;
  final String openingTime;
  final String closingTime;
  final String category;
  final double rating;
  final String? description;
  final String sellerId;
  final ShopStatus status;
  final List<String> customCategories;
  final DateTime createdAt;

  SellerShop({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.openingTime,
    required this.closingTime,
    required this.category,
    required this.rating,
    this.description,
    required this.sellerId,
    this.status = ShopStatus.Pending,
    this.customCategories = const [],
    required this.createdAt,
  });

  // Factory constructor to create a SellerShop from a JSON map
  factory SellerShop.fromJson(Map<String, dynamic> json) {
    // Note: The keys here must match the column names from your database/view.
    // This example assumes we are querying a view that provides all necessary fields.
    return SellerShop(
      id: json['id'].toString(), // Convert int from DB to String
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      openingTime: json['opening_time'] as String,
      closingTime: json['closing_time'] as String,
      // You'll need a view that joins to get the category name
      category: json['category_name'] as String? ?? 'N/A', 
      rating: (json['rating'] as num).toDouble(),
      description: json['description'] as String?,
      sellerId: json['seller_id'] as String,
      status: _parseShopStatus(json['status'] as String),
      // This assumes custom_categories is a text array in PostgreSQL
      customCategories: List<String>.from(json['custom_categories'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}