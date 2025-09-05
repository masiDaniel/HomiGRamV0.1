import 'dart:convert';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

class BusinessService {
  static Future<bool> updateBusiness({
    required int businessId,
    required Map<String, dynamic> updates,
  }) async {
    if (updates.isEmpty) {
      return false;
    }

    final url = Uri.parse('$devUrl/business/updateBusiness/$businessId/');
    String? token = await UserPreferences.getAuthToken();

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 202) {
      return true;
    } else {
      throw Exception("Failed to update business");
    }
  }
}
