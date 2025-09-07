import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:homi_2/components/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

const devUrl = AppConstants.baseUrl;

const storage = FlutterSecureStorage();

Future<void> saveTokens(String access, String refresh) async {
  await storage.write(key: 'access_token', value: access);
  await storage.write(key: 'refresh_token', value: refresh);
}

Future<void> saveAccessToken(String token) async =>
    await storage.write(key: 'access_token', value: token);

Future<String?> getAccessToken() async {
  return await storage.read(key: 'access_token');
}

Future<String?> getRefreshToken() async {
  return await storage.read(key: 'refresh_token');
}

Future<void> clearTokens() async {
  await storage.deleteAll();
}

Future<String?> refreshAccessToken() async {
  final refreshToken = await getRefreshToken();
  if (refreshToken == null) return null;

  final response = await http.post(
    Uri.parse('$devUrl/accounts/api/token/refresh/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refresh': refreshToken}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final newAccess = data['access'];
    await saveAccessToken(newAccess);
    log("✅ Access token refreshed");
    return newAccess;
  } else {
    log("❌ Refresh token expired or invalid");
    await clearTokens();
    return null;
  }
}
