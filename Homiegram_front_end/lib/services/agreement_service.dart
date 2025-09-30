import 'package:homi_2/components/api_client.dart';

class AgreementService {
  Future<bool> renewAgreement(int agreementId) async {
    final response = await apiPost(
      "/renew-contract/$agreementId/",
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> terminateAgreement(int agreementId) async {
    final response = await apiPost(
      "/houses/request-contract-termination/$agreementId/",
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
