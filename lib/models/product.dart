class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.itemCode = '',
    this.costPrice = 0,
    this.unit = 'PCS',
    this.categoryId = '',
    this.isVeg = true,
  });

  final String id;
  final String itemCode;
  final String name;
  final double price;
  final double costPrice;
  final String unit;
  final String categoryId;
  final String category;
  final String imageUrl;
  final bool isVeg;
}

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    this.note,
  });

  final Product product;
  final int quantity;
  final String? note;

  double get amount => product.price * quantity;

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}
