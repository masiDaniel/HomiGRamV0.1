import 'dart:convert';
import 'package:homi_2/models/amenities.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';

import 'package:http/http.dart' as http;

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

Future<List<Amenities>> fetchAmenities() async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };

    final response = await http.get(Uri.parse('$devUrl/houses/amenities'),
        headers: headersWithToken);

    if (response.statusCode == 200) {
      final List<dynamic> amenitiesData = json.decode(response.body);

      final List<Amenities> amenities =
          amenitiesData.map((json) => Amenities.fromJSon(json)).toList();

      return amenities;
    } else {
      throw Exception('failed to fetch arguments');
    }
  } catch (e) {
    rethrow;
  }
}

Future<List<Amenities>> fetchAllAmenities() async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };

    final response = await http.get(Uri.parse('$devUrl/houses/amenities'),
        headers: headersWithToken);

    if (response.statusCode == 200) {
      final List<dynamic> amenitiesData = json.decode(response.body);

      final List<Amenities> amenities =
          amenitiesData.map((json) => Amenities.fromJSon(json)).toList();

      return amenities;
    } else {
      throw Exception('failed to fetch arguments');
    }
  } catch (e) {
    rethrow;
  }
}
