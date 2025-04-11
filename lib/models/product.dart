class Product {
  final String id; // Agregamos ID para identificar cada producto en la subcolección
  final String name;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] is int ? data['price'].toDouble() : data['price']) ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
    };
  }
}