import 'dart:convert';

import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;

Future<String> getOrCreatePrivateChatRoom(int recieverId) async {
  String? authToken;
  authToken = await UserPreferences.getAuthToken();
  final url = Uri.parse('$devUrl/chat/get-or-create-room/');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Token $authToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "receiver_id": recieverId,
    }),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data['room_name'];
  } else {
    throw Exception('Failed to create chat room');
  }
}
