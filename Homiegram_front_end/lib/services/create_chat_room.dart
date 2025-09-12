import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/models/chat.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;
Future<ChatRoom> getOrCreatePrivateChatRoom(int recieverId) async {
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
    return ChatRoom.fromJson(data);
  } else {
    throw Exception('Failed to create chat room');
  }
}
