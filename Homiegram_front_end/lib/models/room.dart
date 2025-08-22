class GetRooms {
  final int roomId;
  final String roomName;
  final int noOfBedrooms;
  final String sizeInSqMeters;
  final String rentAmount;
  final bool occuiedStatus;
  final String roomImages;
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
      required this.apartmentID,
      required this.tenantId,
      required this.rentStatus});

  factory GetRooms.fromJSon(Map<String, dynamic> json) {
    return GetRooms(
        roomId: json['id'] ?? 0,
        roomName: json['room_name'] ?? '',
        noOfBedrooms: json['number_of_bedrooms'],
        sizeInSqMeters: json['size_in_sq_meters'],
        rentAmount: json['rent'],
        occuiedStatus: json['occupied'] ?? false,
        roomImages: json['room_images'] ?? '',
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
}
