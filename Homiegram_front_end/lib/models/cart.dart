class Cart {
  final int id;
  final int userId;
  final List<int> products;

  Cart({
    required this.id,
    required this.userId,
    required this.products,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['user'],
      products: List<int>.from(json['products']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'products': products,
    };
  }
}
