import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import '../auth/auth_session.dart';
import '../models/customer.dart';
import '../models/delivery_partner.dart';
import '../models/product.dart';

class DashboardException implements Exception {
  const DashboardException(this.message);
  final String message;
  @override
  String toString() => message;
}

// ─── Parsed result ────────────────────────────────────────────────────────────
class DashboardData {
  const DashboardData({
    required this.categories,
    required this.products,
    required this.walkinCustomers,
    required this.creditCustomers,
    required this.deliveryPartners,
  });

  final List<String> categories; // includes 'Show All' as first entry
  final List<Product> products;
  final List<CreditCustomer> walkinCustomers;
  final List<CreditCustomer> creditCustomers;
  final List<DeliveryPartner> deliveryPartners;
}

// ─── API ──────────────────────────────────────────────────────────────────────
class DashboardApi {
  DashboardApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _dashboardUrl = ApiConfig.dashboardUrl;

  Future<DashboardData> load(AuthSession session) async {
    final body = {
      'username': session.user.email,
      'password': session.user.password,
      'auth_token': session.authToken,
      'restaurantid': session.user.restaurantId,
    };

    debugPrint('DASHBOARD REQUEST url=$_dashboardUrl');
    debugPrint('DASHBOARD REQUEST body=$body');

    try {
      final response = await _client
          .post(
            Uri.parse(_dashboardUrl),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('DASHBOARD RESPONSE status=${response.statusCode}');
      debugPrint('DASHBOARD RESPONSE body=${response.body}');

      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) {
        throw const DashboardException('Unexpected response from server');
      }
      if (json['success'] != true) {
        throw DashboardException(
          json['message'] as String? ?? 'Failed to load dashboard',
        );
      }
      return _parse(json);
    } on DashboardException {
      rethrow;
    } on TimeoutException {
      throw const DashboardException('Request timed out. Please try again.');
    } on FormatException catch (e) {
      debugPrint('DASHBOARD ERROR format=$e');
      throw const DashboardException('Unexpected response from server');
    } on http.ClientException catch (e) {
      debugPrint('DASHBOARD ERROR client=$e');
      throw const DashboardException(
        'Unable to connect. Check your internet connection.',
      );
    } catch (e) {
      debugPrint('DASHBOARD ERROR $e');
      throw const DashboardException(
        'Unable to connect. Check your internet connection.',
      );
    }
  }

  DashboardData _parse(Map<String, dynamic> json) {
    // ── categories ──────────────────────────────────────────────────────────
    final rawCats = (json['categories'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    // Build a id→name map for product resolution
    final catMap = <String, String>{
      for (final c in rawCats) '${c['id']}': '${c['name'] ?? ''}',
    };
    final categoryNames = ['Show All', ...catMap.values];

    // ── products ────────────────────────────────────────────────────────────
    final products = (json['productdtls'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .where((p) {
          final title = (p['title'] as String? ?? '').trim();
          final price = p['sellprice'];
          return title.isNotEmpty &&
              price != null &&
              price.toString().isNotEmpty;
        })
        .map((p) {
          final categoryId = '${p['categoryid'] ?? ''}';
          final categoryName = catMap[categoryId] ?? '';
          final vegCode = int.tryParse('${p['veg'] ?? 0}') ?? 0;
          // 1 = veg, 2 = non-veg, 3 = egg / other → treat ≠1 as non-veg
          final isVeg = vegCode == 1;
          final imageUrl = ApiConfig.productImageUrl('${p['picture'] ?? ''}');
          final unit = '${p['unit'] ?? ''}'.trim();
          debugPrint('PRODUCT IMAGE url=$imageUrl title=${p['title']}');
          return Product(
            id: '${p['id']}',
            itemCode: '${p['itemcode'] ?? ''}',
            name: (p['title'] as String).trim(),
            price: double.tryParse('${p['sellprice']}') ?? 0,
            costPrice: double.tryParse('${p['costprice'] ?? 0}') ?? 0,
            unit: unit.isEmpty ? 'PCS' : unit,
            categoryId: categoryId,
            category: categoryName,
            imageUrl: imageUrl,
            isVeg: isVeg,
          );
        })
        .toList();

    // ── customers ────────────────────────────────────────────────────────────
    // customertype: 1 = walkin, 2 = delivery, 3 = credit
    final walkinCustomers = <CreditCustomer>[];
    final creditCustomers = <CreditCustomer>[];
    final deliveryPartners = <DeliveryPartner>[];

    for (final c in (json['custdtls'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()) {
      final id = '${c['id']}';
      final name = (c['name'] as String? ?? '').trim();
      final mobile = '${c['mobile'] ?? ''}';
      final type = int.tryParse('${c['customertype'] ?? 0}') ?? 0;

      if (type == 2) {
        deliveryPartners.add(DeliveryPartner(id: id, name: name));
      } else if (type == 3) {
        creditCustomers.add(CreditCustomer(id: id, name: name, phone: mobile));
      } else {
        // type 1 and any others → walkin
        walkinCustomers.add(CreditCustomer(id: id, name: name, phone: mobile));
      }
    }

    return DashboardData(
      categories: categoryNames,
      products: products,
      walkinCustomers: walkinCustomers,
      creditCustomers: creditCustomers,
      deliveryPartners: deliveryPartners,
    );
  }
}
