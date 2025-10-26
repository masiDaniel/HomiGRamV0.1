import 'package:homi_2/models/tenancy_agreement_model.dart';

class RoomWithAgreement {
  final int id;
  final String roomName;
  final int noOfBedrooms;
  final String sizeInSqMeters;
  final String rentAmount;
  final bool occupiedStatus;
  final String roomImages;
  final List<String>? images;
  final int apartmentId;
  final int tenantId;
  final bool rentStatus;
  final Agreement? agreement;

  RoomWithAgreement({
    required this.id,
    required this.roomName,
    required this.noOfBedrooms,
    required this.sizeInSqMeters,
    required this.rentAmount,
    required this.occupiedStatus,
    required this.roomImages,
    this.images,
    required this.apartmentId,
    required this.tenantId,
    required this.rentStatus,
    this.agreement,
  });

  factory RoomWithAgreement.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['images'] != null) {
      images = (json['images'] as List)
          .map((imgObj) => imgObj['image'] as String)
          .toList();
    }
    return RoomWithAgreement(
      id: json['id'] ?? 0,
      roomName: json['room_name'] ?? '',
      noOfBedrooms: json['number_of_bedrooms'] ?? 0,
      sizeInSqMeters: json['size_in_sq_meters'] ?? '',
      rentAmount: json['rent'] ?? '',
      occupiedStatus: json['occupied'] ?? false,
      roomImages: json['room_images'] ?? '',
      images: images,
      apartmentId: json['apartment'] ?? 0,
      tenantId: json['tenant'] ?? 0,
      rentStatus: json['rent_status'] ?? false,
      agreement: json['agreement'] != null
          ? Agreement.fromJson(json['agreement'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "room_name": roomName,
      "number_of_bedrooms": noOfBedrooms,
      "size_in_sq_meters": sizeInSqMeters,
      "rent": rentAmount,
      "apartment": apartmentId,
      "tenant": tenantId,
    };
  }
}
