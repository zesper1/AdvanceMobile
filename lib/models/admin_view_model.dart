import 'package:flutter/foundation.dart';

// Enum to represent the shop status, matching your PostgreSQL enum.
// Using an enum in Dart is safer and cleaner than using raw strings.
enum ShopStatus {
  pending,
  approved,
  rejected,
  unknown, // A default for unexpected values
}

// Enum for availability status.
enum AvailabilityStatus {
  Open,
  Closed,
  unknown,
}

/// A data model that represents a single row from the `admin_shops_view`.
@immutable
class AdminShopView {
  final int shopId;
  final String ownerId;
  final String shopName;
  final String? description;
  final String? logoUrl;
  final ShopStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AvailabilityStatus availabilityStatus;
  final String? openingTime;
  final String? closingTime;
  final double rating;
  final int categoryId;
  final String categoryName;
  final List<String> subcategories;

  const AdminShopView({
    required this.shopId,
    required this.ownerId,
    required this.shopName,
    this.description,
    this.logoUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.availabilityStatus,
    this.openingTime,
    this.closingTime,
    required this.rating,
    required this.categoryId,
    required this.categoryName,
    required this.subcategories,
  });

  /// Factory constructor to create an AdminShopView instance from a JSON map.
  /// This is used to parse the response from Supabase.
  factory AdminShopView.fromJson(Map<String, dynamic> json) {
    return AdminShopView(
      shopId: json['shop_id'] as int,
      ownerId: json['owner_id'] as String,
      shopName: json['shop_name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      
      // Parse the status string into our ShopStatus enum
      status: _parseShopStatus(json['status'] as String?),
      
      // Parse ISO 8601 date strings into DateTime objects
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),

      // Parse the availability status string into our enum
      availabilityStatus: _parseAvailabilityStatus(json['availability_status'] as String?),

      // Times are stored as strings
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      
      // Ensure rating is parsed as a double
      rating: (json['rating'] as num).toDouble(),
      
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      
      // The JSONB array from the view comes as a List<dynamic>.
      // We convert it to a List<String>.
      subcategories: List<String>.from(json['subcategories'] ?? []),
    );
  }

  // Helper function to parse the shop status enum from a string
  static ShopStatus _parseShopStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return ShopStatus.pending;
      case 'approved':
        return ShopStatus.approved;
      case 'rejected':
        return ShopStatus.rejected;
      default:
        return ShopStatus.unknown;
    }
  }

  // Helper function to parse the availability status enum from a string
  static AvailabilityStatus _parseAvailabilityStatus(String? status) {
    switch (status) {
      case 'Open':
        return AvailabilityStatus.Open;
      case 'Closed':
        return AvailabilityStatus.Closed;
      default:
        return AvailabilityStatus.unknown;
    }
  }
}