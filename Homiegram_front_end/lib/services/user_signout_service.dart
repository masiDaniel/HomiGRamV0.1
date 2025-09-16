import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:http/http.dart' as http;

const Map<String, String> headers = {
  "Content-Type": "application/json",
};
const devUrl = AppConstants.baseUrl;
Future logoutUser() async {
  String? token = await getAccessToken();
  String? refreshToken = await getRefreshToken();
  try {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Bearer $token',
    };
    final response = await http.post(
      Uri.parse("$devUrl/accounts/logout/"),
      headers: headersWithToken,
      body: {
        "refresh": refreshToken,
      },
    );

    if (response.statusCode == 205) {
      return true;
    }
  } catch (e) {
    rethrow;
  }
  return false;
}
