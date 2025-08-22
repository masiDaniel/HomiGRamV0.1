import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:homi_2/models/ads.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;

Future<List<Ad>> fetchAds() async {
  String? token = await UserPreferences.getAuthToken();

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Token $token',
  };

  final response = await http.get(
    Uri.parse('$devUrl/houses/getAdverstisments/?status=active'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    log("ad feting was succesful");

    return jsonResponse.map((ad) => Ad.fromJson(ad)).toList();
  } else {
    throw Exception('Failed to load advertisements');
  }
}

Future<String> postAds(Ad adRequest, File? imageFile) async {
  String? token = await UserPreferences.getAuthToken();

  final uri = Uri.parse('$devUrl/houses/submitAdvertisment/');
  final request = http.MultipartRequest('POST', uri);
  request.headers['Authorization'] = 'Token $token';

  request.fields['title'] = adRequest.title;
  request.fields['description'] = adRequest.description;
  request.fields['start_date'] = adRequest.startDate;
  request.fields['end_date'] = adRequest.endDate;

  if (imageFile != null) {
    log("Attaching image: ${imageFile.path}");
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
  } else {
    log("No image selected");
  }

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      return jsonResponse['message'] ?? 'Ad created successfully';
    } else {
      throw Exception(
          'Failed to submit ad. Status: ${response.statusCode}, Body: $responseBody');
    }
  } catch (e, stack) {
    log("Exception occurred: $e");
    log("STACKTRACE: $stack");
    rethrow;
  }
}
