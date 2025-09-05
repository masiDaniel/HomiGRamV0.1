import 'package:homi_2/components/constants.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:http/http.dart' as http;

const devUrl = AppConstants.baseUrl;

class AgreementService {
  Future<bool> renewAgreement(int agreementId, String token) async {
    final url = Uri.parse("$devUrl/renew-contract/$agreementId/");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Renew failed: ${response.body}");
      return false;
    }
  }

  Future<bool> terminateAgreement(int agreementId) async {
    String? token = await UserPreferences.getAuthToken();
    final url =
        Uri.parse("$devUrl/houses/request-contract-termination/$agreementId/");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Termination failed: ${response.body}");
      return false;
    }
  }
}
