import 'dart:convert';
import 'dart:math';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/models/room_with_agrrement_model.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';

import 'package:http/http.dart' as http;

const Map<String, String> headers = {
  "Content-Type": "application/json",
};
List<GetRooms> allRooms = [];
List<RoomWithAgreement> allRoomsAndAgreements = [];
String? houseId;

Future<List<GetRooms>> fetchRooms() async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };

    final response = await http.get(Uri.parse('$devUrl/houses/getRooms/'),
        headers: headersWithToken);

    if (response.statusCode == 200) {
      final List<dynamic> roomData = json.decode(response.body);

      try {
        final List<GetRooms> rooms = roomData.map((json) {
          return GetRooms.fromJSon(json);
        }).toList();

        allRooms = rooms;
      } catch (e) {
        log("StackTrace: $e" as num);
      }

      return allRooms;
    } else {
      throw Exception('failed to fetch arguments');
    }
  } catch (e) {
    rethrow;
  }
}

Future<List<RoomWithAgreement>> fetchRoomsWithAgreements() async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };

    final response = await http.get(Uri.parse('$devUrl/houses/getMyRooms/'),
        headers: headersWithToken);

    if (response.statusCode == 200) {
      final List<dynamic> roomData = json.decode(response.body);

      try {
        final List<RoomWithAgreement> rooms = roomData.map((json) {
          return RoomWithAgreement.fromJson(json);
        }).toList();

        allRoomsAndAgreements = rooms;
      } catch (e) {
        log("StackTrace: $e" as num);
      }

      return allRoomsAndAgreements;
    } else {
      throw Exception('failed to fetch arguments');
    }
  } catch (e) {
    rethrow;
  }
}

Future<List<GetRooms>> fetchRoomsByHouse(int houseId) async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };

    final response = await http.get(Uri.parse('$devUrl/houses/getRooms/'),
        headers: headersWithToken);

    if (response.statusCode == 200) {
      final List<dynamic> roomData = json.decode(response.body);

      final List<GetRooms> rooms =
          roomData.map((json) => GetRooms.fromJSon(json)).toList();

      final filteredRooms =
          rooms.where((room) => room.apartmentID == houseId).toList();

      allRooms = rooms;

      return filteredRooms;
    } else {
      throw Exception('failed to fetch arguments');
    }
  } catch (e) {
    rethrow;
  }
}

Future<String> postRoomsByHouse(int houseId, GetRooms newRoom) async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };

    final response = await http.post(
      Uri.parse('$devUrl/houses/getRooms/'),
      headers: headersWithToken,
      body: jsonEncode([newRoom.tojson()]),
    );

    if (response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('failed to post new room  ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}
