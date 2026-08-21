class Product {
  final int id;
  final String name;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int createdBy;
  final String? createdByUsername;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.createdByUsername,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      createdBy: json['created_by'],
      createdByUsername: json['created_by_username'],
    );
  }
}
