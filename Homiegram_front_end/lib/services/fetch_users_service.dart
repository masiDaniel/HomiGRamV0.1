import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/comments.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

Future<List<GetComments>> fetchUsersComment() async {
  String? token = await getAccessToken();
  try {
    final response =
        await http.get(Uri.parse('$devUrl/accounts/getUsers/'), headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> commentData = json.decode(response.body);

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
