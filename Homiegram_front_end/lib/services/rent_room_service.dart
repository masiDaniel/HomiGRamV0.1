import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;
Future<String?> rentRoom(int houseId, int roomId) async {
  String? token = await getAccessToken();
  try {
    final response =
        await http.post(Uri.parse("$devUrl/houses/assign-tenant/$houseId/"),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
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
