import 'dart:convert';
import 'dart:io';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/cart.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

class CartService {
  Future<Cart?> getCart(int? userId) async {
    String? token = await getAccessToken();

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(
        Uri.parse("$devUrl/business/getCarts/"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return Cart.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } on SocketException {
      throw Exception("No internet connection");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<Cart?> createCart(int? userId) async {
    String? token = await getAccessToken();

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var data = {"user": userId};
    try {
      final response = await http.post(Uri.parse("$devUrl/business/getCarts/"),
          headers: headers, body: jsonEncode(data));

      if (response.statusCode == 201) {
        print("cart response ${jsonDecode(response.body)}");
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return Cart.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> addToCart(int cartId, int productIds) async {
    String? token = await getAccessToken();

    try {
      final response = await http.post(
        Uri.parse("$devUrl/business/postCartItems/"),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body:
            jsonEncode({"cart": cartId, "product": productIds, "quantity": 1}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

Future<bool> removeItemFromCart(int cartId, List<int> productIds) async {
  try {
    final response = await http.patch(
      Uri.parse("$devUrl$cartId/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "products": productIds,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}
