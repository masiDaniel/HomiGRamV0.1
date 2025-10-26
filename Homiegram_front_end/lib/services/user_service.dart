import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/get_users.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

class UserService {
  static Future<List<GerUsers>> fetchUsers() async {
    String? token = await getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('$devUrl/accounts/getUsers/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) => GerUsers.fromJSon(user)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }
}
