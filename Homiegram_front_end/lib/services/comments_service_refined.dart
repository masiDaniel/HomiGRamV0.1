import 'dart:convert';

import 'package:homi_2/components/constants.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

class CommentService {
  static Future<int> deleteComment(int commentId) async {
    String? token = await UserPreferences.getAuthToken();
    final url = Uri.parse('$devUrl/comments/deleteComments/$commentId/');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    final response = await http.delete(url, headers: headers);

    return response.statusCode;
  }

  static Future<int> sendReply({
    required int parentCommentId,
    required int houseId,
    required int? userId,
    required String replyText,
  }) async {
    String? token = await UserPreferences.getAuthToken();
    final url = Uri.parse("$devUrl/comments/post/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        "house_id": houseId,
        "user_id": userId,
        "comment": replyText,
        "parent": parentCommentId,
      }),
    );

    return response.statusCode;
  }

  static Future<int> reactToComment({
    required int commentId,
    required String action,
  }) async {
    final userId = await UserPreferences.getUserId();
    if (userId == null) return 401;

    String? token = await UserPreferences.getAuthToken();
    final url = Uri.parse("$devUrl/comments/post/");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        "comment_id": commentId,
        "action": action,
        "user_id": userId,
      }),
    );

    return response.statusCode;
  }
}
