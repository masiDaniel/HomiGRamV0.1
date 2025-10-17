import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/models/room_with_agrrement_model.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;
List<GetRooms> allRooms = [];
List<RoomWithAgreement> allRoomsAndAgreements = [];
String? houseId;

Future<List<GetRooms>> fetchRooms() async {
  String? token = await getAccessToken();
  try {
    final response =
        await http.get(Uri.parse('$devUrl/houses/getRooms/'), headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    });

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
  String? token = await getAccessToken();
  try {
    final response =
        await http.get(Uri.parse('$devUrl/houses/getMyRooms/'), headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    });

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
  String? token = await getAccessToken();
  try {
    final response =
        await http.get(Uri.parse('$devUrl/houses/getRooms/'), headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    });

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

Future<String> postRoomsByHouse(GetRooms newRoom) async {
  final dio = Dio();
  FormData formData = FormData();

  // Add text fields
  formData.fields.add(MapEntry('room_name', newRoom.roomName));
  formData.fields.add(MapEntry('rent', newRoom.rentAmount.toString()));
  formData.fields
      .add(MapEntry('number_of_bedrooms', newRoom.noOfBedrooms.toString()));
  formData.fields
      .add(MapEntry('size_in_sq_meters', newRoom.sizeInSqMeters.toString()));
  formData.fields.add(MapEntry('apartment', newRoom.apartmentID.toString()));

  // Add images if available
  if (newRoom.images != null && newRoom.images!.isNotEmpty) {
    for (int i = 0; i < newRoom.images!.length; i++) {
      String imagePath = newRoom.images![i];
      var file = await MultipartFile.fromFile(imagePath,
          filename: imagePath.split('/').last);
      formData.files.add(MapEntry('image', file)); // Single key 'image' is fine
    }
  }

  String? token = await getAccessToken();
  try {
    final response = await dio.post(
      '$devUrl/houses/getRooms/',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data.toString();
    } else {
      throw Exception('Failed with status ${response.statusCode}');
    }
  } on DioException catch (e) {
    throw Exception(
        'Failed to post new room: ${e.response?.data ?? e.message}');
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
