import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:http/http.dart' as http;
import 'package:homi_2/models/bookmark.dart';

const devUrl = AppConstants.baseUrl;
Future<List<Bookmark>> fetchBookmarks() async {
  String? token = await getAccessToken();

  final response = await http.get(
    Uri.parse('$devUrl/houses/getBookmarks/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((bookmark) => Bookmark.fromJson(bookmark)).toList();
  } else {
    throw Exception('Failed to load bookmarks');
  }
}
