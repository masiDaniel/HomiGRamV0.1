import 'package:homi_2/models/room.dart';

class GetHouse {
  final int houseId;
  final String name;
  final String rentAmount;
  final int rating;
  final String description;
  final List<String>? images;
  final String bankName;
  final String accountNumber;
  final List<int> amenities;
  final int? locationDetail;
  final double? latitude;
  final double? longitude;
  final int landlordId;
  final int? caretakerId;
  final String? contractUrl;
  final Map<String, List<GetRooms>>? rooms;

  GetHouse(
      {required this.houseId,
      required this.name,
      required this.rentAmount,
      required this.rating,
      required this.description,
      this.images,
      required this.bankName,
      required this.accountNumber,
      required this.amenities,
      required this.landlordId,
      required this.locationDetail,
      this.latitude,
      this.longitude,
      this.caretakerId,
      this.contractUrl,
      this.rooms});

  @override
  String toString() {
    return '''GetHouse {
  name: $name,
  rentAmount: $rentAmount,
  rating: $rating,
  description: $description,
  images: $images,
  amenities: $amenities,
  landlordId: $landlordId,
  houseId: $houseId,
  bankName: $bankName,
  accountNumber: $accountNumber,
  location_detail: $locationDetail,
    rooms: $rooms
}''';
  }

  factory GetHouse.fromJSon(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['images'] != null) {
      images = (json['images'] as List)
          .map((imgObj) => imgObj['image'] as String)
          .toList();
    }

    Map<String, List<GetRooms>>? roomsMap;

    if (json['rooms'] != null) {
      roomsMap = {};

      (json['rooms'] as Map<String, dynamic>).forEach((key, value) {
        final roomList = (value as List<dynamic>)
            .where((roomJson) => roomJson != null)
            .map((roomJson) => GetRooms.fromJSon(roomJson))
            .toList();

        roomsMap![key] = roomList;
      });
    }
    return GetHouse(
      houseId: json['id'] ?? '',
      name: json['name'] ?? '',
      rentAmount: json['rent_amount'] ?? '',
      rating: json['rating'] ?? '',
      description: json['description'] ?? '',
      images: images,
      bankName: json['payment_bank_name'] ?? '',
      accountNumber: json['payment_account_number'] ?? '',
      amenities: List<int>.from(json['amenities'] ?? []),
      landlordId: json['landlord_id'],
      caretakerId: json['caretaker'],
      contractUrl: json['contract_file'],
      locationDetail: json['location_detail'],
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      rooms: roomsMap,
    );
  }

  Map<String, dynamic> tojson() {
    return {
      'name': name,
      'rentAmount': rentAmount,
      'rating': rating,
      'description': description,
      'amenities': amenities,
      'landlordId': landlordId,
    };
  }
}
