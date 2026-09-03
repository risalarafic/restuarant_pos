/// POST /api/orders
/// Saves the current POS cart as an order.
class SaveOrderRequest {
  const SaveOrderRequest({
    required this.customerType,
    required this.items,
    required this.itemCount,
    required this.subTotal,
    required this.total,
    this.creditCustomerId,
    this.walkinPhone,
    this.deliveryTeamId,
  });

  /// WALKIN | CREDIT | DELIVERY
  final String customerType;
  final String? creditCustomerId;
  final String? walkinPhone;
  final String? deliveryTeamId;
  final List<SaveOrderItem> items;
  final int itemCount;
  final double subTotal;
  final double total;

  Map<String, dynamic> toJson() => {
        'customer_type': customerType,
        'credit_customer_id': creditCustomerId,
        'walkin_phone': walkinPhone,
        'delivery_team_id': deliveryTeamId,
        'items': items.map((item) => item.toJson()).toList(),
        'item_count': itemCount,
        'sub_total': subTotal,
        'total': total,
      };

  factory SaveOrderRequest.fromJson(Map<String, dynamic> json) {
    return SaveOrderRequest(
      customerType: json['customer_type'] as String? ?? 'WALKIN',
      creditCustomerId: json['credit_customer_id'] as String?,
      walkinPhone: json['walkin_phone'] as String?,
      deliveryTeamId: json['delivery_team_id'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => SaveOrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      itemCount: json['item_count'] as int? ?? 0,
      subTotal: (json['sub_total'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SaveOrderItem {
  const SaveOrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.amount,
    this.note,
    this.isVeg = true,
  });

  final String productId;
  final String title;
  final double price;
  final int quantity;
  final double amount;
  final String? note;
  final bool isVeg;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'title': title,
        'price': price,
        'quantity': quantity,
        'amount': amount,
        'note': note,
        'is_veg': isVeg,
      };

  factory SaveOrderItem.fromJson(Map<String, dynamic> json) {
    return SaveOrderItem(
      productId: json['product_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      note: json['note'] as String?,
      isVeg: json['is_veg'] as bool? ?? true,
    );
  }
}

class SaveOrderResponse {
  const SaveOrderResponse({
    required this.orderId,
    required this.orderNumber,
    required this.status,
  });

  final String orderId;
  final int orderNumber;
  final String status;

  factory SaveOrderResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SaveOrderResponse(
      orderId: data['order_id'] as String? ?? '',
      orderNumber: data['order_number'] as int? ?? 0,
      status: data['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'order_number': orderNumber,
        'status': status,
      };
}
