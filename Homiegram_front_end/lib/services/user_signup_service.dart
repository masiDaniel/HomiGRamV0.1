import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/models/user_signup.dart';
import 'package:http/http.dart' as http;

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

/// what is the difference of using Future<UserSignUp?> fetchUserSignIp and just writting Future fetchUserSignUp?
///

const devUrl = AppConstants.baseUrl;

Future<UserSignUp?> fetchUserSignUp(
    String firstName, String lastName, String email, String password) async {
  try {
    final response = await http
        .post(
          Uri.parse("$devUrl/accounts/signup/"),
          headers: headers,
          body: jsonEncode({
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "password": password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserSignUp.fromJSon(jsonResponse);
    } else if (response.statusCode == 400) {
      String errorMessage = _extractErrorMessage(jsonResponse);
      throw Exception(errorMessage);
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  } on SocketException {
    throw Exception("No internet connection. Please check your network.");
  } on TimeoutException {
    throw Exception("Connection timed out. Please try again.");
  } catch (e) {
    throw Exception("Unexpected error: $e");
  }
}

String _extractErrorMessage(Map<String, dynamic> jsonResponse) {
  final errors = <String>[];
  jsonResponse.forEach((key, value) {
    if (value is List && value.isNotEmpty) {
      errors.add(value.first.toString());
    } else if (value is String) {
      errors.add(value);
    }
  });
  return errors.isNotEmpty ? errors.join("\n") : "Unknown error occurred.";
}
