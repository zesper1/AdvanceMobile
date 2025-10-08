// models/menu_item_model.dart
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;

  final String stallId;
  final bool isFavorite; // NEW: Add this field

  final List<String> customCategories; // Add this field

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.stallId,
    this.isFavorite = false, // Default to false
    this.customCategories = const [], // Default to empty list
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? stock,
    String? category,
    String? stallId,
    bool? isFavorite, // NEW: Add to copyWith
    List<String>? customCategories,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,

      stallId: stallId ?? this.stallId,
      isFavorite: isFavorite ?? this.isFavorite, // NEW: Assign in copyWith
      customCategories: customCategories ?? this.customCategories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,

      'stallId': stallId,
      'customCategories': customCategories, // Add to map
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      stock: map['stock'] ?? 0,

      stallId: map['stallId'] ?? '',
      customCategories:
          List<String>.from(map['customCategories'] ?? []), // Parse from map
    );
  }
}
