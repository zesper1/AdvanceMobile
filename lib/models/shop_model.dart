enum ShopStatus { open, breakTime, closed, pending }

class Shop {
  final int id;
  final String ownerId; // seller UUID
  final String name;
  final int category;
  final String description;
  final String operatingHours;
  final ShopStatus status;
  final double rating;
  final int views;

  Shop({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.category,
    required this.description,
    required this.operatingHours,
    required this.status,
    required this.rating,
    required this.views,
  });

  factory Shop.fromMap(Map<String, dynamic> map) {
  // shop_views is nested from the join
final shopView = (map['shop_views'] as List?)?.isNotEmpty == true
    ? map['shop_views'][0] as Map<String, dynamic>
    : null;


    return Shop(
      id: map['id'] as int,
      ownerId: map['seller'] as String,
      name: map['shop_name'] ?? '',
      category: map['category'] as int,
      description: map['description'] ?? '',
      operatingHours: shopView?['operating_hours'] ?? '',
      status: _statusFromString(shopView?['status'] ?? 'pending'),
      rating: (shopView?['rating'] ?? 0).toDouble(),
      views: shopView?['views'] ?? 0,
    );
  }

  static ShopStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return ShopStatus.open;
      case 'breaktime':
        return ShopStatus.breakTime;
      case 'closed':
        return ShopStatus.closed;
      case 'pending':
      default:
        return ShopStatus.pending;
    }
  }

  Shop copyWith({
    int? id,
    String? ownerId,
    String? name,
    int? category,
    String? description,
    String? operatingHours,
    ShopStatus? status,
    double? rating,
    int? views,
  }) {
    return Shop(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      operatingHours: operatingHours ?? this.operatingHours,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      views: views ?? this.views,
    );
  }
}
