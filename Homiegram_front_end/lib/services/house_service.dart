import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/room.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

class HouseService {
  static Future<bool> assignCaretaker({
    required int houseId,
    required int? userId,
  }) async {
    String? token = await getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse('$devUrl/houses/assign-caretaker/'),
      headers: headers,
      body: json.encode({
        'house_id': houseId,
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      return true; // success
    } else {
      throw Exception('Failed to assign caretaker');
    }
  }

  static Future<bool> removeCaretaker({
    required int houseId,
    required int caretakerId,
  }) async {
    String? token = await getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(
      Uri.parse('$devUrl/houses/remove-caretaker/'),
      headers: headers,
      body: json.encode({
        'house_id': houseId,
        'caretaker_id': caretakerId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = json.decode(response.body)['error'] ?? 'Unknown error';
      throw Exception(error);
    }
  }

  static Future<GetRooms> updateRoom({
    required int roomId,
    required String roomName,
    required String numberOfBedrooms,
    required String sizeInSqMeters,
    required String rent,
    required int apartmentId,
    String? imagePath,
  }) async {
    String? token = await getAccessToken();
    final uri = Uri.parse("$devUrl/houses/updateRoom/$roomId/");

    var request = http.MultipartRequest("PATCH", uri);

    request.fields['room_name'] = roomName;
    request.fields['number_of_bedrooms'] = numberOfBedrooms;
    request.fields['size_in_sq_meters'] = sizeInSqMeters;
    request.fields['rent'] = rent;
    request.fields['apartment'] = apartmentId.toString();

    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          imagePath,
        ),
      );
    }

    request.headers['Authorization'] = 'Bearer $token';
    print('>>> REQUEST DEBUG <<<');
    print('URL: ${request.url}');
    print('METHOD: ${request.method}');
    print('HEADERS: ${request.headers}');
    print('FIELDS: ${request.fields}');
    print('FILES: ${request.files.map((f) => f.filename).toList()}');

    final response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      print("this is the response $responseBody");
      final updatedJson = json.decode(responseBody);
      return GetRooms.fromJSon(updatedJson);
    } else {
      throw Exception("Failed to update room (status ${response.statusCode})");
    }
  }
}
