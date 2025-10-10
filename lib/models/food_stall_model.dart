enum AvailabilityStatus { Open, Closed, OnBreak }

class FoodStall {
  final String id;
  final String name;
  final String imageUrl;
  final AvailabilityStatus availability;
  final String openingTime;
  final String closingTime;
  final String category;
  final double rating;
  bool isFavorite;
  final String description;
  final String location;
  final bool isOpen;
  final List<String> customCategories;

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
    this.location = '',
    this.isOpen = false,
    this.customCategories = const [],
  });
}