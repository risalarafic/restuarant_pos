/// GET /api/dashboard
/// Loads everything the POS dashboard needs in one response.
class DashboardResponse {
  const DashboardResponse({
    required this.restaurant,
    required this.categories,
    required this.products,
    required this.creditCustomers,
    required this.deliveryTeams,
  });

  final DashboardRestaurant restaurant;
  final List<DashboardCategory> categories;
  final List<DashboardProduct> products;
  final List<DashboardCreditCustomer> creditCustomers;
  final List<DashboardDeliveryTeam> deliveryTeams;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return DashboardResponse(
      restaurant: DashboardRestaurant.fromJson(
        data['restaurant'] as Map<String, dynamic>? ?? {},
      ),
      categories: (data['categories'] as List<dynamic>? ?? [])
          .map((item) => DashboardCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
      products: (data['products'] as List<dynamic>? ?? [])
          .map((item) => DashboardProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
      creditCustomers: (data['credit_customers'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                DashboardCreditCustomer.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      deliveryTeams: (data['delivery_teams'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                DashboardDeliveryTeam.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'restaurant': restaurant.toJson(),
        'categories': categories.map((item) => item.toJson()).toList(),
        'products': products.map((item) => item.toJson()).toList(),
        'credit_customers':
            creditCustomers.map((item) => item.toJson()).toList(),
        'delivery_teams': deliveryTeams.map((item) => item.toJson()).toList(),
      };
}

class DashboardRestaurant {
  const DashboardRestaurant({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory DashboardRestaurant.fromJson(Map<String, dynamic> json) {
    return DashboardRestaurant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class DashboardCategory {
  const DashboardCategory({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory DashboardCategory.fromJson(Map<String, dynamic> json) {
    return DashboardCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class DashboardProduct {
  const DashboardProduct({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.isVeg,
  });

  final String id;
  final String categoryId;
  final String title;
  final double price;
  final String imageUrl;
  final bool isVeg;

  factory DashboardProduct.fromJson(Map<String, dynamic> json) {
    return DashboardProduct(
      id: json['id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['image'] as String? ?? json['image_url'] as String? ?? '',
      isVeg: json['is_veg'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'title': title,
        'price': price,
        'image': imageUrl,
        'is_veg': isVeg,
      };
}

class DashboardCreditCustomer {
  const DashboardCreditCustomer({
    required this.id,
    required this.name,
    required this.phone,
  });

  final String id;
  final String name;
  final String phone;

  factory DashboardCreditCustomer.fromJson(Map<String, dynamic> json) {
    return DashboardCreditCustomer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
      };
}

class DashboardDeliveryTeam {
  const DashboardDeliveryTeam({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory DashboardDeliveryTeam.fromJson(Map<String, dynamic> json) {
    return DashboardDeliveryTeam(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
