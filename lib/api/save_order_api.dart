import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_session.dart';
import '../models/product.dart';
import 'api_config.dart';
import 'save_order_request.dart';

class SaveOrderException implements Exception {
  const SaveOrderException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SaveOrderApi {
  SaveOrderApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _url = ApiConfig.saveOrderUrl;

  Future<SaveOrderResponse> save({
    required AuthSession session,
    required String customerId,
    required String phone,
    required List<CartItem> cart,
  }) async {
    final request = SaveOrderRequest(
      username: session.user.email,
      password: session.user.password,
      authToken: session.authToken,
      restaurantId: session.user.restaurantId,
      customerId: customerId,
      phone: phone,
      items: cart
          .map(
            (item) => SaveOrderItem(
              productId: item.product.id,
              itemCode: item.product.itemCode,
              title: item.product.name,
              price: item.product.price,
              costPrice: item.product.costPrice,
              unit: item.product.unit,
              quantity: item.quantity,
              amount: item.amount,
            ),
          )
          .toList(),
    );

    final body = request.toJson();
    debugPrint('SAVE ORDER REQUEST url=$_url');
    debugPrint('SAVE ORDER REQUEST body=$body');

    try {
      final response = await _client
          .post(
            Uri.parse(_url),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('SAVE ORDER RESPONSE status=${response.statusCode}');
      debugPrint('SAVE ORDER RESPONSE body=${response.body}');

      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) {
        throw const SaveOrderException('Unexpected response from server');
      }

      final result = SaveOrderResponse.fromJson(json);
      if (!result.success) {
        throw SaveOrderException(result.message ?? 'Failed to save order');
      }
      return result;
    } on SaveOrderException {
      rethrow;
    } on TimeoutException {
      throw const SaveOrderException('Request timed out. Please try again.');
    } on FormatException catch (error) {
      debugPrint('SAVE ORDER ERROR format=$error');
      throw const SaveOrderException('Unexpected response from server');
    } on http.ClientException catch (error) {
      debugPrint('SAVE ORDER ERROR client=$error');
      throw const SaveOrderException(
        'Unable to connect. Check your internet connection.',
      );
    } catch (error) {
      debugPrint('SAVE ORDER ERROR $error');
      throw const SaveOrderException(
        'Unable to connect. Check your internet connection.',
      );
    }
  }
}
