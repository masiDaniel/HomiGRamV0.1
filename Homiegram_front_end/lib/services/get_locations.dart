import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

Future<List<Locations>> fetchLocations() async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final response =
        await http.get(Uri.parse('$devUrl/houses/locations/'), headers: {
      "Content-Type": "application/json",
      'Authorization': 'Token $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> locationsData = json.decode(response.body);

      final List<Locations> locations =
          locationsData.map((json) => Locations.fromJSon(json)).toList();

      return locations;
    } else {
      throw Exception('failed to fetch arguments');
    }
  } catch (e) {
    rethrow;
  }
}
