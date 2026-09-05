class SaveOrderRequest {
  const SaveOrderRequest({
    required this.username,
    required this.password,
    required this.authToken,
    required this.restaurantId,
    required this.customerId,
    required this.phone,
    required this.items,
  });

  final String username;
  final String password;
  final String authToken;
  final String restaurantId;
  final String customerId;
  final String phone;
  final List<SaveOrderItem> items;

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'auth_token': authToken,
        'restaurantid': restaurantId,
        'customer_id': customerId,
        'phone': phone,
        'items': items.map((item) => item.toJson()).toList(),
      };
}

class SaveOrderItem {
  const SaveOrderItem({
    required this.productId,
    required this.itemCode,
    required this.title,
    required this.price,
    required this.costPrice,
    required this.unit,
    required this.quantity,
    required this.amount,
  });

  final String productId;
  final String itemCode;
  final String title;
  final double price;
  final double costPrice;
  final String unit;
  final int quantity;
  final double amount;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'itemcode': itemCode,
        'title': title,
        'price': price.toString(),
        'costprice': costPrice.toString(),
        'unit': unit,
        'quantity': quantity,
        'amount': amount,
      };
}

class SaveOrderResponse {
  const SaveOrderResponse({
    required this.success,
    this.message,
    this.lastReceipt,
  });

  final bool success;
  final String? message;
  final String? lastReceipt;

  factory SaveOrderResponse.fromJson(Map<String, dynamic> json) {
    return SaveOrderResponse(
      success: json['success'] == true,
      message: json['message'] as String?,
      lastReceipt: json['lastreceipt']?.toString(),
    );
  }
}
