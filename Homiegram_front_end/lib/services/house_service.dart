import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/amenities.dart';
import 'package:homi_2/models/comments.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/models/house_rating.dart';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/services/comments_service_refined.dart';
import 'package:homi_2/services/fetch_bookmarks.dart';
import 'package:homi_2/services/get_amenities.dart';
import 'package:homi_2/services/get_house_service.dart';
import 'package:homi_2/services/get_locations.dart';
import 'package:homi_2/services/post_comments_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

const devUrl = AppConstants.baseUrl;

class HouseService {
  static Future<bool> assignCaretaker({
    required int houseId,
    required int? userId,
  }) async {
    String? token = await getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse('$devUrl/houses/assign-caretaker/'),
      headers: headers,
      body: json.encode({
        'house_id': houseId,
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      return true; // success
    } else {
      throw Exception('Failed to assign caretaker');
    }
  }

  static Future<bool> removeCaretaker({
    required int houseId,
    required int caretakerId,
  }) async {
    String? token = await getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(
      Uri.parse('$devUrl/houses/remove-caretaker/'),
      headers: headers,
      body: json.encode({
        'house_id': houseId,
        'caretaker_id': caretakerId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = json.decode(response.body)['error'] ?? 'Unknown error';
      throw Exception(error);
    }
  }

  static Future<GetRooms> updateRoom({
    required int roomId,
    required String roomName,
    required String numberOfBedrooms,
    required String sizeInSqMeters,
    required String rent,
    required int apartmentId,
    String? imagePath,
  }) async {
    String? token = await getAccessToken();
    final uri = Uri.parse("$devUrl/houses/updateRoom/$roomId/");

    var request = http.MultipartRequest("PATCH", uri);

    request.fields['room_name'] = roomName;
    request.fields['number_of_bedrooms'] = numberOfBedrooms;
    request.fields['size_in_sq_meters'] = sizeInSqMeters;
    request.fields['rent'] = rent;
    request.fields['apartment'] = apartmentId.toString();

    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        request.files
            .add(await http.MultipartFile.fromPath('images', file.path));
      } else {}
    }

    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      final updatedJson = json.decode(responseBody);
      return GetRooms.fromJSon(updatedJson);
    } else {
      throw Exception("Failed to update room (status ${response.statusCode})");
    }
  }

  static Future<bool> toggleBookmark({
    required int houseId,
    required bool currentlyBookmarked,
    required BuildContext context,
    required String houseName,
  }) async {
    try {
      String? token = await getAccessToken();
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      http.Response response;

      if (currentlyBookmarked) {
        // Remove bookmark
        response = await http.post(
          Uri.parse('$devUrl/houses/bookmark/remove/$houseId/'),
          headers: headers,
        );
      } else {
        // Add bookmark
        response = await http.post(
          Uri.parse('$devUrl/houses/bookmark/add/$houseId/'),
          headers: headers,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!context.mounted) return currentlyBookmarked; // safety

        // Show dialog
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title:
                  Text(currentlyBookmarked ? 'Bookmark Removed' : 'Bookmarked'),
              content: Text(currentlyBookmarked
                  ? 'This house has been removed from your bookmarks.'
                  : '$houseName has been added to your bookmarks.'),
              actions: [
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0x95154D07)),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child:
                      const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );

        return !currentlyBookmarked; // new state
      } else {
        throw Exception(
            'Failed to toggle bookmark (status ${response.statusCode})');
      }
    } catch (e) {
      log("Error toggling bookmark: $e");
      rethrow;
    }
  }

  static Future<List<Locations>> fetchHouseLocations(int houseId) async {
    try {
      List<Locations> fetchedLocations = await fetchLocations();
      return fetchedLocations;
    } catch (e) {
      log('Error fetching locations: $e');
      return [];
    }
  }

  static Future<List<Amenities>> fetchHouseAmenities(GetHouse house) async {
    try {
      List<Amenities> fetchedAmenities = await fetchAmenities();
      return fetchedAmenities
          .where((amenity) => house.amenities.contains(amenity.id))
          .toList();
    } catch (e) {
      log('Error fetching amenities: $e');
      return [];
    }
  }

  static Future<List<GetHouse>> fetchBookmarkedHouses(int? userId) async {
    final bookmarks = await fetchBookmarks();
    final allHouses = await fetchHouses();

    final houseIdsForUser = bookmarks
        .where((bookmark) => bookmark.user == userId)
        .map((bookmark) => bookmark.house)
        .toList();

    return allHouses
        .where((house) => houseIdsForUser.contains(house.houseId))
        .toList();
  }

  static String getLocationName({
    required int locationId,
    required List<Locations> locations,
  }) {
    final location = locations.firstWhere(
      (loc) => loc.locationId == locationId,
      orElse: () => Locations(
        locationId: 0,
        area: "unknown",
        town: "unknown",
        county: "unknown",
      ),
    );
    return '${location.area}, ${location.town}, ${location.county}';
  }

  static List<String> getRoomCategories(GetHouse house) {
    if (house.rooms != null && house.rooms!.isNotEmpty) {
      final categories = house.rooms!.keys.toList();
      categories.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      return categories;
    } else {
      return [];
    }
  }

  static Future<List<GetComments>> fetchCommentsHouseC(int houseId) async {
    try {
      return await CommentsService.fetchComments(houseId);
    } catch (e) {
      log("Error fetching comments: $e");
      return [];
    }
  }

  // Add a comment
  static Future<void> addComment({
    required int houseId,
    required int userId,
    required String comment,
    bool nested = true,
    String nestedId = '3',
  }) async {
    await CommentsService.postComment(
      houseId: houseId.toString(),
      userId: userId.toString(),
      comment: comment,
      nested: nested,
      nestedId: nestedId,
    );
  }

  // Delete comment
  static Future<int> deleteComment(int commentId) async {
    try {
      return await CommentService.deleteComment(commentId);
    } catch (e) {
      log("Error deleting comment: $e");
      rethrow;
    }
  }

  // React to comment
  static Future<int> reactToComment({
    required int commentId,
    required String action,
  }) async {
    return await CommentService.reactToComment(
      commentId: commentId,
      action: action,
    );
  }

  static Future<HouseRating?> submitRating(int houseId, int rating,
      {String? comment}) async {
    String? token = await getAccessToken();
    final url = Uri.parse('$devUrl/houses/rate/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'house': houseId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return HouseRating.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error.toString());
    }
  }

  // Fetch all ratings of the logged-in user
  Future<List<HouseRating>> fetchMyRatings() async {
    String? token = await getAccessToken();
    final url = Uri.parse('$devUrl/houses/rate/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HouseRating.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch ratings');
    }
  }
}
