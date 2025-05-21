class CartItemModel {
  final String id;
  final String name;
  final String image;
  final double price;
  int quantity;
  bool isSelect;

  CartItemModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    this.isSelect = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'isSelect': isSelect
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      isSelect: json['isSelect'] ?? false,
    );
  }
}
