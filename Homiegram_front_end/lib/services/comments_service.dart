import 'dart:convert';
import 'dart:developer';
import 'package:homi_2/models/comments.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

Future<List<GetComments>> fetchComments(int houseId) async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };

    final response = await http.get(
        Uri.parse('$devUrl/comments/post/?house_id=$houseId'),
        headers: headersWithToken);

    if (response.statusCode == 200) {
      final List<dynamic> commentData = json.decode(response.body);

      log("Fetched Comments");

      final List<GetComments> comments =
          commentData.map((json) => GetComments.fromJSon(json)).toList();

      return comments;
    } else {
      throw Exception('failed to fetch arguments');
    }
  } catch (e) {
    rethrow;
  }
}
