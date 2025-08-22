import 'dart:convert';
import 'package:homi_2/models/user_signup.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

/// what is the difference of using Future<UserSignUp?> fetchUserSignIp and just writting Future fetchUserSignUp?
///
Future<UserSignUp?> fetchUserSignUp(
    String firstName, String lastName, String email, String password) async {
  try {
    final response = await http.post(Uri.parse("$devUrl/accounts/signup/"),
        headers: headers,
        body: jsonEncode({
          "first_name": firstName,
          "last_name": lastName,
          "email": email,
          "password": password,
        }));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return UserSignUp.fromJSon(jsonResponse);
    } else {
      throw Exception("request failed with status: ${response.statusCode}");
    }
  } catch (e) {
    rethrow;
  }
}
