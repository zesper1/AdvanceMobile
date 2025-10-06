class Category {
  final int id;
  final String name;
  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['category_id'], name: json['category_name']);
  }
}

class Subcategory {
  final int id;
  final String name;
  Subcategory({required this.id, required this.name});

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(id: json['subcategory_id'], name: json['subcategory_name']);
  }
}