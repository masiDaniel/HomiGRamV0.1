import 'dart:convert';

import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';

import 'package:http/http.dart' as http;

const Map<String, String> headers = {
  "Content-Type": "application/json",
};
List<GetHouse> allHouses = [];
String? houseId;

Future<List<GetHouse>> fetchHouses() async {
  String? token = await UserPreferences.getAuthToken();
  try {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };

    final response = await http.get(Uri.parse('$devUrl/houses/gethouses/'),
        headers: headersWithToken);

    if (response.statusCode == 200) {
      final List<dynamic> housesData = json.decode(response.body);
      print("house data $housesData");

      final List<GetHouse> houses =
          housesData.map((json) => GetHouse.fromJSon(json)).toList();

      allHouses = houses;
      return houses;
    } else {
      throw Exception('failed to fetch arguments');
    }
  } catch (e) {
    rethrow;
  }
}
