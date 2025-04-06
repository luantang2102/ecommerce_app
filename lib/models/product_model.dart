class Product {
  String? id;
  String name;
  String description;
  double price;
  String imageUrl;
  int stock;
  List<String> categories;
  double rating;
  String status; // Add the status field

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    this.categories = const [],
    this.rating = 0.0,
    this.status = 'available', // Default status is 'available'
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'categories': categories,
      'rating': rating,
      'status': status, // Include status in the map
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      imageUrl: map['imageUrl'],
      stock: map['stock'],
      categories: List<String>.from(map['categories'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'available', // Default to 'available' if status is missing
    );
  }
}