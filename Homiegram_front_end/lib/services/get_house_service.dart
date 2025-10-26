import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:http/http.dart' as http;

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

const devUrl = AppConstants.baseUrl;
List<GetHouse> allHouses = [];
String? houseId;

Future<List<GetHouse>> fetchHouses() async {
  String? token = await getAccessToken();
  try {
    final response =
        await http.get(Uri.parse('$devUrl/houses/gethouses/'), headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> housesData = json.decode(response.body);

      final List<GetHouse> houses =
          housesData.map((json) => GetHouse.fromJSon(json)).toList();

      // allHouses = houses;
      return houses;
    } else {
      throw Exception('failed to fetch arguments');
    }
  } catch (e) {
    rethrow;
  }
}
