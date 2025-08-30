import 'dart:convert';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;

Future<String?> rentRoom(int houseId, int roomId) async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    final response = await http.post(
        Uri.parse("$devUrl/houses/assign-tenant/$houseId/"),
        headers: headers,
        body: jsonEncode({"room_id": roomId}));

    if (response.statusCode == 200) {
      return "Room successfully rented!";
    }

    final responseData = jsonDecode(response.body);
    if (responseData.containsKey('error')) {
      return responseData['error'];
    }

    return "An unexpected error occurred: ${response.statusCode}";
  } catch (e) {
    return "Something went wrong: ${e.toString()}";
  }
}
