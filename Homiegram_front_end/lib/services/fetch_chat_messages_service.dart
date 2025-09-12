import 'dart:convert';
import 'package:homi_2/chat%20feature/DB/chat_db_helper.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/models/chat.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;
Future<List<ChatRoom>> fetchChatRooms() async {
  String? authToken;
  authToken = await UserPreferences.getAuthToken();
  final url = Uri.parse('$devUrl/chat/my-chat-rooms/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Token $authToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final chatRooms = data.map((item) => ChatRoom.fromJson(item)).toList();

    final dbHelper = DatabaseHelper();

    for (var room in chatRooms) {
      // Save chatroom
      await dbHelper.insertOrUpdateChatroom(room);

      // Save messages
      for (var msg in room.messages) {
        await dbHelper.insertOrUpdateMessage(msg, room.id);
      }
    }
    return chatRooms;
  } else {
    throw Exception('Failed to load chat rooms');
  }
}
