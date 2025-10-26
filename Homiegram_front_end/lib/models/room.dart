class GetRooms {
  final int roomId;
  final String roomName;
  final int noOfBedrooms;
  final String sizeInSqMeters;
  final String rentAmount;
  final bool occuiedStatus;
  final String roomImages;
  final List<String>? images;
  final int apartmentID;
  final int tenantId;
  final bool rentStatus;

  GetRooms(
      {required this.roomId,
      required this.roomName,
      required this.noOfBedrooms,
      required this.sizeInSqMeters,
      required this.rentAmount,
      required this.occuiedStatus,
      required this.roomImages,
      this.images,
      required this.apartmentID,
      required this.tenantId,
      required this.rentStatus});

  factory GetRooms.fromJSon(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['images'] != null) {
      images = (json['images'] as List)
          .map((imgObj) => imgObj['image'] as String)
          .toList();
    }
    return GetRooms(
        roomId: json['id'] ?? 0,
        roomName: json['room_name'] ?? '',
        noOfBedrooms: json['number_of_bedrooms'],
        sizeInSqMeters: json['size_in_sq_meters'],
        rentAmount: json['rent'],
        occuiedStatus: json['occupied'] ?? false,
        roomImages: json['room_images'] ?? '',
        images: images,
        apartmentID: json['apartment'] ?? 0,
        tenantId: json['tenant'] ?? 0,
        rentStatus: json['rent_status'] ?? false);
  }

  Map<String, dynamic> tojson() {
    return {
      "room_name": roomName,
      "number_of_bedrooms": noOfBedrooms,
      "size_in_sq_meters": sizeInSqMeters,
      "rent": rentAmount,
      "apartment": apartmentID,
    };
  }

  static fromJson(roomJson) {}
}
