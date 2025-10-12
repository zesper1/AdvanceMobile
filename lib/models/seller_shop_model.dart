
enum ShopAvailabilityStatus { Open, Closed, OnBreak }

enum ShopStatus { Pending, Approved, Rejected }

// Helper function for ShopStatus
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

// 2. ADD HELPER FUNCTION for the new nullable availability status
ShopAvailabilityStatus? _parseAvailabilityStatus(String? status) {
  if (status == null) return null; // Return null if the value from DB is null
  switch (status.toLowerCase()) {
    case 'open':
      return ShopAvailabilityStatus.Open;
    case 'closed':
      return ShopAvailabilityStatus.Closed;
    case 'onbreak':
      return ShopAvailabilityStatus.OnBreak;
    default:
      return null; // Return null for any other unexpected value
  }
}

class SellerShop {
  final String id;
  final String name;
  final String? imageUrl;
  final String openingTime;
  final String closingTime;
  final String category;
  final int categoryId;
  final double rating;
  final String? description;
  final String sellerId;
  final ShopStatus status;
  final List<String> customCategories;
  final DateTime createdAt;
  // 3. ADD THE NEW NULLABLE PROPERTY
  final ShopAvailabilityStatus? availabilityStatus;

  SellerShop({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.openingTime,
    required this.closingTime,
    required this.category,
    required this.categoryId,
    required this.rating,
    this.description,
    required this.sellerId,
    this.status = ShopStatus.Pending,
    this.customCategories = const [],
    required this.createdAt,
    this.availabilityStatus, // Added to constructor
  });

  SellerShop copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? openingTime,
    String? closingTime,
    String? category,
    int? categoryId,
    double? rating,
    String? description,
    String? sellerId,
    ShopStatus? status,
    List<String>? customCategories,
    DateTime? createdAt,
    ShopAvailabilityStatus? availabilityStatus, // Added to copyWith
  }) {
    return SellerShop(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      sellerId: sellerId ?? this.sellerId,
      status: status ?? this.status,
      customCategories: customCategories ?? this.customCategories,
      createdAt: createdAt ?? this.createdAt,
      // Handle the new property in copyWith
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    );
  }

  // Factory constructor to create a SellerShop from JSON
  factory SellerShop.fromJson(Map<String, dynamic> json) {
    return SellerShop(
      // Safely convert id to string
      id: json['id']?.toString() ?? '',

      // Safe string fields
      name: json['name'] as String? ?? 'Unnamed Shop',

      // Nullable image URL with default fallback
      imageUrl: json['image_url'] as String? ??
          'https://media.licdn.com/dms/image/v2/C560BAQHvjs3O4Utmdw/company-logo_200_200/company-logo_200_200/0/1631351760522?e=2147483647&v=beta&t=98Nb6ha1qF7VFgRtzDHP0WzmNbTlI_r26j4Q4rm3nMg',

      // Default for times
      openingTime: json['opening_time'] as String? ?? '00:00:00',
      closingTime: json['closing_time'] as String? ?? '00:00:00',

      // Category
      category: json['category'] as String? ?? 'N/A',
      categoryId: json['category_id'] as int? ?? 0,

      // Rating handling
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,

      // Optional description
      description: json['description'] as String?,

      // Required seller ID
      sellerId: json['seller_id'] as String? ?? 'UNKNOWN_SELLER',

      // Enum parsing
      status: _parseShopStatus(json['status'] as String? ?? 'pending'),

      // 4. FETCH AND PARSE the new nullable status from JSON
      availabilityStatus:
          _parseAvailabilityStatus(json['availability_status'] as String?),

      // Custom categories list
      customCategories: List<String>.from(json['custom_categories'] ?? []),

      // Date parsing
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at'] as String),
    );
  }
}