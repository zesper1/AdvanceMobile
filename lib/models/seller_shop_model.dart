// models/seller_shop_model.dart
enum ShopStatus { Pending, Approved, Rejected }

class SellerShop {
  final String id;
  final String name;
  final String imageUrl;
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
    required this.imageUrl,
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

  SellerShop copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? openingTime,
    String? closingTime,
    String? category,
    double? rating,
    String? description,
    String? sellerId,
    ShopStatus? status,
    List<String>? customCategories,
    DateTime? createdAt,
  }) {
    return SellerShop(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      sellerId: sellerId ?? this.sellerId,
      status: status ?? this.status,
      customCategories: customCategories ?? this.customCategories,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}