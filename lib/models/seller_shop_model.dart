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
  // In models/seller_shop_model.dart

factory SellerShop.fromJson(Map<String, dynamic> json) {
  return SellerShop(
    // Safely convert id to string, providing a fallback if it's null.
    id: json['id']?.toString() ?? '',

    // Use `as String?` and provide a default value with `??`.
    name: json['name'] as String? ?? 'Unnamed Shop',

    // This was already safe since imageUrl is nullable.
    imageUrl: json['image_url'] as String ?? 'https://media.licdn.com/dms/image/v2/C560BAQHvjs3O4Utmdw/company-logo_200_200/company-logo_200_200/0/1631351760522?e=2147483647&v=beta&t=98Nb6ha1qF7VFgRtzDHP0WzmNbTlI_r26j4Q4rm3nMg',

    // Provide defaults for time strings.
    openingTime: json['opening_time'] as String? ?? '00:00:00',
    closingTime: json['closing_time'] as String? ?? '00:00:00',
    
    // Corrected key to 'category' and kept the null-safe logic.
    category: json['category'] as String? ?? 'N/A', 

    // Safely handle numbers that could be int or double.
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    
    // This was already safe since description is nullable.
    description: json['description'] as String?,
    
    // sellerId is required, so a fallback prevents crashes but indicates a data issue.
    sellerId: json['seller_id'] as String? ?? 'UNKNOWN_SELLER',
    
    // Safely parse the status, defaulting to 'pending'.
    status: _parseShopStatus(json['status'] as String? ?? 'pending'),
    
    // This was already safe.
    customCategories: List<String>.from(json['custom_categories'] ?? []),
    
    // Safely parse DateTime, defaulting to the current time if null.
    createdAt: json['created_at'] == null
        ? DateTime.now()
        : DateTime.parse(json['created_at'] as String),
  );
}
}