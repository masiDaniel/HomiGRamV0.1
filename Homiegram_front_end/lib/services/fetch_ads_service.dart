import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/ads.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

Future<http.Response> authorizedGet(String url) async {
  String? token = await getAccessToken();

  var response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 401) {
    final newAccess = await refreshAccessToken();

    if (newAccess != null) {
      response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $newAccess',
        },
      );
    } else {
      throw Exception("Session expired. Please log in again.");
    }
  }

  return response;
}

Future<List<Ad>> fetchAds() async {
  final response = await authorizedGet(
    '$devUrl/houses/getAdverstisments/?status=active',
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    log("✅ ad fetching was successful");
    return jsonResponse.map((ad) => Ad.fromJson(ad)).toList();
  } else {
    throw Exception('Failed to load advertisements');
  }
}

Future<String> postAds(Ad adRequest, File? imageFile) async {
  String? token = await getAccessToken();

  final uri = Uri.parse('$devUrl/houses/submitAdvertisment/');
  final request = http.MultipartRequest('POST', uri);
  request.headers['Authorization'] = 'Bearer $token';

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
