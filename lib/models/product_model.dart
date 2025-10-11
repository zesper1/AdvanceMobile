// lib/models/product_model.dart

import 'package:flutter/foundation.dart';

@immutable
class Product {
  final int productId;
  final int shopId;
  final String productName;
  final String? description;
  final double price;
  final int quantity;
  final bool isAvailable;
  final String? imageUrl;
  final int? subcategoryId;      // <-- ADDED
  final String? subcategoryName;  // <-- ADDED
  final List<String> customCategories;

  const Product({
    required this.productId,
    required this.shopId,
    required this.productName,
    this.description,
    required this.price,
    required this.quantity,
    required this.isAvailable,
    this.imageUrl,
    this.subcategoryId,      // <-- ADDED
    this.subcategoryName,  // <-- ADDED
    this.customCategories = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] as int,
      shopId: json['shop_id'] as int,
      productName: json['product_name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      isAvailable: json['is_available'] as bool,
      imageUrl: json['image_url'] as String?,
      
      // ADDED: These lines parse the new nullable fields from the view.
      subcategoryId: json['subcategory_id'] as int?,
      subcategoryName: json['subcategory_name'] as String?,
      
      customCategories: List<String>.from(json['custom_categories'] ?? []),
    );
  }
}