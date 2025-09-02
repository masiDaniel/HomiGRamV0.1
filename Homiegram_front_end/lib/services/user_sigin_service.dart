import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:homi_2/models/user_signin.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

//  'https://hommiegram.azurewebsites.net'
// String productionUrl = 'http://192.168.0.106:8000/';
// String devUrl = 'https://hommiegram.azurewebsites.net';

// String chatUrl = 'wss://hommiegram.azurewebsites.net';

String devUrl = 'http://192.168.0.107:8000';

String chatUrl = 'ws://192.168.0.107:8000';
Future fetchUserSignIn(
    BuildContext context, String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse("$devUrl/accounts/login/"),
      headers: headers,
      body: jsonEncode({
        "email": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);

      await UserPreferences.saveUserData(userData);

      return UserRegistration.fromJSon(userData);
    }
  } catch (e) {
    log("Error during sign-in: $e");
    return null;
  }
  return null;
}

Future updateUserInfo(Map<String, dynamic> updateData) async {
  String? token = await UserPreferences.getAuthToken();
  try {
    log("this is the data $updateData");
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $token',
    };
    final response = await http
        .patch(
          Uri.parse("$devUrl/accounts/user/update/"),
          headers: headersWithToken,
          body: jsonEncode(updateData),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return true;
    }
  } catch (e) {
    rethrow;
  }
  return null;
}

// TODO : have this to take images data also
Future updateHouseInfo(Map<String, dynamic> updateData, int houseId) async {
  String? token = await UserPreferences.getAuthToken();
  try {
    var uri = Uri.parse("$devUrl/houses/updateHouse/$houseId/");
    var request = http.MultipartRequest('PATCH', uri);

    // Add text fields
    updateData.forEach((key, value) {
      if (key != 'images') {
        request.fields[key] = value.toString();
      }
    });

    // Add images as files
    if (updateData['images'] != null) {
      for (var imagePath in updateData['images']) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            imagePath,
          ),
        );
      }
    }

    request.headers.addAll({
      ...headers,
      'Authorization': 'Token $token',
    });

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      log('House updated successfully');
      return true;
    } else {
      log('Update failed: ${response.statusCode} ${response.body}');
      return false;
    }
  } catch (e) {
    rethrow;
  }
}

Future<bool> updateProfilePicture(String imagePath) async {
  String? token = await UserPreferences.getAuthToken();

  try {
    final uri = Uri.parse("$devUrl/accounts/user/update/");

    var request = http.MultipartRequest('PATCH', uri);
    request.headers.addAll({
      'Authorization': 'Token $token',
      'Content-Type': 'multipart/form-data',
    });

    request.files.add(await http.MultipartFile.fromPath(
      'profile_pic',
      imagePath,
      contentType: MediaType('image', 'jpeg'),
    ));

    final response = await request.send().timeout(const Duration(seconds: 10));

    final responseBody = await response.stream.bytesToString();

    final userData = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      const String keyProfilePic = 'profilePicture';
      await prefs.setString(keyProfilePic, userData['profile_pic'] ?? 'N/A');
      return true;
    } else {
      final respStr = await response.stream.bytesToString();
      log("Failed to update profile picture: $respStr");
    }
  } catch (e) {
    log("Exception occurred: $e");
    rethrow;
  }

  return false;
}
