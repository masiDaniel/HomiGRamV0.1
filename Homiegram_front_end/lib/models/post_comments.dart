import 'dart:convert';
import 'dart:developer';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;

class PostComments {
  static Future<void> postComment({
    required String houseId,
    required String userId,
    required String comment,
    required bool nested,
    required String nestedId,
  }) async {
    String? token = await UserPreferences.getAuthToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
    try {
      final response = await http.post(
        Uri.parse("$devUrl/comments/post/"),
        headers: headers,
        body: jsonEncode({
          "house_id": houseId,
          "user_id": userId,
          "comment": comment,
          "nested": nested,
          "nested_id": nestedId,
        }),
      );

      if (response.statusCode == 200) {
        log('comment posted succesfully!');
      } else {
        log('failed to post comment: ${response.statusCode}');
      }
    } catch (e) {
      log('error positng comment: $e');
    }
  }
}
