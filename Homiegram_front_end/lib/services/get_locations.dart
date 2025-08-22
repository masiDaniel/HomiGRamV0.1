import 'dart:convert';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

Future<List<Locations>> fetchLocations() async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };

    final response = await http.get(Uri.parse('$devUrl/houses/locations/'),
        headers: headersWithToken);

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
