enum ShopStatus { open, closed, breakTime }

class Shop {
  final String id;
  final String name;
  final String category;
  final ShopStatus status;
  final double rating;
  final List<String> bestPicks;

  Shop({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.rating,
    required this.bestPicks,
  });

  Shop copyWith({
    String? id,
    String? name,
    String? category,
    ShopStatus? status,
    double? rating,
    List<String>? bestPicks,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      bestPicks: bestPicks ?? this.bestPicks,
    );
  }
}
