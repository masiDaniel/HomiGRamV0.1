import 'dart:developer';

import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;

class PostBookmark {
  static Future<void> postBookmark({
    required int houseId,
  }) async {
    String? token = await UserPreferences.getAuthToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
    try {
      final response = await http.post(
        Uri.parse("$devUrl/houses/bookmark/add/$houseId/"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        log('Comment posted successfully!', name: 'CommentLogger');
      } else {
        log('failed to post comment: ${response.statusCode}');
      }
    } catch (e) {
      log('error positng comment: $e');
    }
  }

  static Future<void> removeBookmark({
    required int houseId,
  }) async {
    String? token = await UserPreferences.getAuthToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
    try {
      final response = await http.post(
        Uri.parse("$devUrl/houses/bookmark/remove/$houseId/"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        log('Bookmark removed succesfully!');
      } else {
        log('failed to delete Bookmark: ${response.statusCode}');
      }
    } catch (e) {
      log('error Deleting Bookmark: $e');
    }
  }
}

class Bookmark {
  final int id;
  final int user;
  final int house;
  final String createdAt;

  Bookmark(
      {required this.id,
      required this.user,
      required this.house,
      required this.createdAt});

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      user: json['user'],
      house: json['house'],
      createdAt: json['created_at'],
    );
  }
}
