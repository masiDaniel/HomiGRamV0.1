import 'dart:convert';

import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;
Future logoutUser() async {
  String? token = await getAccessToken();
  String? refreshToken = await getRefreshToken();

  try {
    final headersWithToken = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.post(
      Uri.parse("$devUrl/accounts/logout/"),
      headers: headersWithToken,
      body: jsonEncode({
        "refresh": refreshToken,
      }),
    );

    if (response.statusCode == 205) {
      return true;
    }
  } catch (e) {
    rethrow;
  }
  return false;
}
