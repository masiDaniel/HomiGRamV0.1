import 'dart:convert';
import 'dart:developer';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/comments.dart';

import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

class CommentsService {
  static Future<List<GetComments>> fetchComments(int houseId) async {
    String? token = await getAccessToken();

    try {
      final response = await http.get(
        Uri.parse('$devUrl/comments/post/?house_id=$houseId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> commentData = json.decode(response.body);
        log("Fetched Comments");
        return commentData.map((json) => GetComments.fromJSon(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch comments (status: ${response.statusCode})');
      }
    } catch (e) {
      log("Error fetching comments: $e");
      rethrow;
    }
  }

  // Post a comment
  static Future<void> postComment({
    required String houseId,
    required String userId,
    required String comment,
    required bool nested,
    required String nestedId,
  }) async {
    String? token = await getAccessToken();

    try {
      final response = await http.post(
        Uri.parse("$devUrl/comments/post/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "house_id": houseId,
          "user_id": userId,
          "comment": comment,
          "nested": nested,
          "nested_id": nestedId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Comment posted successfully!');
      } else {
        log('Failed to post comment: ${response.statusCode}');
        throw Exception('Failed to post comment');
      }
    } catch (e) {
      log('Error posting comment: $e');
      rethrow;
    }
  }

  // Optional: delete comment
  static Future<int> deleteComment(int commentId) async {
    String? token = await getAccessToken();
    try {
      final response = await http.delete(
        Uri.parse('$devUrl/comments/delete/$commentId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode;
    } catch (e) {
      log("Error deleting comment: $e");
      rethrow;
    }
  }

  // Optional: react to comment
  static Future<int> reactToComment({
    required int commentId,
    required String action,
  }) async {
    String? token = await getAccessToken();
    try {
      final response = await http.post(
        Uri.parse('$devUrl/comments/react/$commentId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"action": action}),
      );
      return response.statusCode;
    } catch (e) {
      log("Error reacting to comment: $e");
      rethrow;
    }
  }
}
