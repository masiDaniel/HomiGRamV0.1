import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/chat.dart';

import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;
Future<ChatRoom> getOrCreatePrivateChatRoom(int recieverId) async {
  String? token = await getAccessToken();
  final url = Uri.parse('$devUrl/chat/get-or-create-room/');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "receiver_id": recieverId,
    }),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return ChatRoom.fromJson(data);
  } else {
    throw Exception('Failed to create chat room');
  }
}
