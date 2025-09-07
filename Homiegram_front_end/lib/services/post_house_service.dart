import 'dart:convert';
import 'dart:developer';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

const devUrl = AppConstants.baseUrl;

class PostHouseService {
  final String apiUrl = '${devUrl}houses/gethouses/';

  Future<bool> addHouse(GetHouse house) async {
    String? token = await getAccessToken();
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(house.tojson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      log('Failed to add house: ${response.statusCode} ${response.body}');
      return false;
    }
  }

  Future<bool> postHouseWithImages(GetHouse house) async {
    final dio = Dio();

    FormData formData = FormData();
    formData.fields.add(MapEntry('name', house.name));
    formData.fields.add(MapEntry('rent_amount', house.rentAmount));
    formData.fields.add(MapEntry('rating', house.rating.toString()));
    formData.fields.add(MapEntry('description', house.description));
    formData.fields
        .add(MapEntry('location_detail', house.locationDetail.toString()));

    formData.fields.add(MapEntry('landlord_id', house.landlordId.toString()));

    for (int amenity in house.amenities) {
      formData.fields.add(MapEntry('amenities', amenity.toString()));
    }

    if (house.images != null) {
      for (int i = 0; i < house.images!.length; i++) {
        String imagePath = house.images![i];

        var file = await MultipartFile.fromFile(imagePath,
            filename: imagePath.split('/').last);

        String fieldName = i == 0 ? 'image' : 'image_$i';

        formData.files.add(MapEntry(
          fieldName,
          file,
        ));
      }
    }
    String? token = await getAccessToken();
    try {
      // print("=== FORM DATA DEBUG START ===");
      // for (var field in formData.fields) {
      //   print("${field.key}: ${field.value}");
      // }
      // for (var file in formData.files) {
      //   print("${file.key}: ${file.value.filename}");
      // }
      // print("=== FORM DATA DEBUG END ===");

      final response = await dio.post(
        '$devUrl/houses/gethouses/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        return true;
      }
      return true;
    } on DioException catch (e) {
      log('Failed to post house: ${e.response?.data}');
      return false;
    }
  }
}
