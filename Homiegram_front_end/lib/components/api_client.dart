import 'package:http/http.dart' as http;
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';

const devUrl = AppConstants.baseUrl;

/// 🔒 Internal function to send a request with token handling
Future<http.Response> _sendRequest(
  String endpoint, {
  required String method,
  Map<String, String>? headers,
  dynamic body,
}) async {
  String? accessToken = await getAccessToken();
  final url = Uri.parse("$devUrl$endpoint");

  Map<String, String> requestHeaders = {
    "Authorization": "Bearer $accessToken",
    if (headers != null) ...headers,
  };

  http.Response response;

  switch (method) {
    case "POST":
      response = await http.post(url, headers: requestHeaders, body: body);
      break;
    case "PUT":
      response = await http.put(url, headers: requestHeaders, body: body);
      break;
    case "PATCH":
      response = await http.patch(url, headers: requestHeaders, body: body);
      break;
    case "DELETE":
      response = await http.delete(url, headers: requestHeaders, body: body);
      break;
    default:
      response = await http.get(url, headers: requestHeaders);
  }

  // If unauthorized, attempt token refresh
  if (response.statusCode == 401) {
    final newAccess = await refreshAccessToken();
    if (newAccess != null) {
      requestHeaders["Authorization"] = "Bearer $newAccess";

      switch (method) {
        case "POST":
          response = await http.post(url, headers: requestHeaders, body: body);
          break;
        case "PUT":
          response = await http.put(url, headers: requestHeaders, body: body);
          break;
        case "PATCH":
          response = await http.patch(url, headers: requestHeaders, body: body);
          break;
        case "DELETE":
          response =
              await http.delete(url, headers: requestHeaders, body: body);
          break;
        default:
          response = await http.get(url, headers: requestHeaders);
      }
    }
  }

  return response;
}

/// 🌐 GET
Future<http.Response> apiGet(
  String endpoint, {
  Map<String, String>? headers,
}) {
  return _sendRequest(endpoint, method: "GET", headers: headers);
}

/// 🌐 POST
Future<http.Response> apiPost(
  String endpoint, {
  Map<String, String>? headers,
  dynamic body,
}) {
  return _sendRequest(endpoint, method: "POST", headers: headers, body: body);
}

/// 🌐 PUT
Future<http.Response> apiPut(
  String endpoint, {
  Map<String, String>? headers,
  dynamic body,
}) {
  return _sendRequest(endpoint, method: "PUT", headers: headers, body: body);
}

/// 🌐 PATCH
Future<http.Response> apiPatch(
  String endpoint, {
  Map<String, String>? headers,
  dynamic body,
}) {
  return _sendRequest(endpoint, method: "PATCH", headers: headers, body: body);
}

/// 🌐 DELETE
Future<http.Response> apiDelete(
  String endpoint, {
  Map<String, String>? headers,
  dynamic body,
}) {
  return _sendRequest(endpoint, method: "DELETE", headers: headers, body: body);
}

/// 📤 Multipart (file uploads)
Future<http.StreamedResponse> apiUploadFile(
  String endpoint,
  Map<String, String> fields,
  String filePath,
) async {
  String? accessToken = await getAccessToken();
  final url = Uri.parse("$devUrl$endpoint");

  final request = http.MultipartRequest("POST", url)
    ..headers["Authorization"] = "Bearer $accessToken"
    ..fields.addAll(fields)
    ..files.add(await http.MultipartFile.fromPath("image", filePath));

  return await request.send();
}
