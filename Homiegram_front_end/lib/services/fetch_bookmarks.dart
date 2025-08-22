import 'dart:convert';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;
import 'package:homi_2/models/bookmark.dart';

Future<List<Bookmark>> fetchBookmarks() async {
  String? token = await UserPreferences.getAuthToken();
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Token $token',
  };

  final response = await http.get(
    Uri.parse('$devUrl/houses/getBookmarks/'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((bookmark) => Bookmark.fromJson(bookmark)).toList();
  } else {
    throw Exception('Failed to load bookmarks');
  }
}
