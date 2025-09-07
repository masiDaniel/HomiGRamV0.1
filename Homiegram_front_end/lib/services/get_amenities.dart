import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/amenities.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;
Future<List<Amenities>> fetchAmenities() async {
  String? token = await getAccessToken();
  try {
    final response =
        await http.get(Uri.parse('$devUrl/houses/amenities'), headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    });

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
  String? token = await getAccessToken();
  try {
    final response =
        await http.get(Uri.parse('$devUrl/houses/amenities'), headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    });

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
