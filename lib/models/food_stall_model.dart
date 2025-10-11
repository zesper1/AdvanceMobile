import 'dart:convert'; // Required for jsonDecode

enum AvailabilityStatus { 
  Open, 
  Closed, 
  OnBreak;

  // Static method to convert database string to enum
  static AvailabilityStatus fromString(String status) {
    if (status == 'Open') return AvailabilityStatus.Open;
    if (status == 'OnBreak') return AvailabilityStatus.OnBreak;
    return AvailabilityStatus.Closed;
  }
}

class FoodStall {
  final int id;
  final String name;
  final String imageUrl;
  final AvailabilityStatus availability;
  final String openingTime;
  final String closingTime;
  final String category;
  final double rating;
  final bool isFavorite; // Removed setter, made final for efficiency
  final String description;
  final List<String> customCategories;
  bool isOpen = false; // Local state, not from DB
  String location;
  FoodStall({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.availability,
    required this.openingTime,
    required this.closingTime,
    required this.category,
    required this.rating,
    this.isFavorite = false,
    this.description = '',
    this.customCategories = const [],
    this.isOpen = false,
    this.location = '',
  });

  // Factory constructor for parsing the Supabase Map data
  factory FoodStall.fromMap(Map<String, dynamic> map) {
    // Parse the custom_categories JSON array string
    final customCategoriesString = map['custom_categories'] as String? ?? '[]';
    final List<String> categories = (jsonDecode(customCategoriesString) as List?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    // Parse time to HH:MM format for display
    String formatTime(String time) => time.split(':').take(2).join(':');

    return FoodStall(
      id: map['shop_id'] as int,
      name: map['shop_name'] as String,
      imageUrl: map['logo_url'] as String? ?? '',
      description: map['description'] as String? ?? '',
      availability: AvailabilityStatus.fromString(map['availability_status'] as String),
      openingTime: formatTime(map['opening_time'] as String),
      closingTime: formatTime(map['closing_time'] as String),
      category: map['category_name'] as String? ?? 'N/A',
      rating: double.tryParse(map['rating'].toString()) ?? 0.0,
      isFavorite: map['is_favorite'] as bool? ?? false, // Assumed to be joined
      customCategories: categories,
    );
  }

  // CopyWith method for local state updates
  FoodStall copyWith({
    int? id,
    String? name,
    String? imageUrl,
    AvailabilityStatus? availability,
    String? openingTime,
    String? closingTime,
    String? category,
    double? rating,
    bool? isFavorite,
    String? description,
    List<String>? customCategories,
  }) {
    return FoodStall(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      availability: availability ?? this.availability,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      customCategories: customCategories ?? this.customCategories,
    );
  }
}