import 'dart:convert';
import 'dart:developer';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';

import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

class PostComments {
  static Future<void> postComment({
    required String houseId,
    required String userId,
    required String comment,
    required bool nested,
    required String nestedId,
  }) async {
    String? token = await getAccessToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
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
