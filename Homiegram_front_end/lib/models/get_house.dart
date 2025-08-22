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
  final int landlordId;
  final int? caretakerId;
  final String? contractUrl;

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
      this.caretakerId,
      this.contractUrl});

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
  location_detail: $locationDetail
}''';
  }

  factory GetHouse.fromJSon(Map<String, dynamic> json) {
    // TODO : have this include upto 10 images. Also refactor the backend
    List<String> images = [];
    if (json['image'] != null) images.add(json['image']);
    if (json['image_1'] != null) images.add(json['image_1']);
    if (json['image_2'] != null) images.add(json['image_2']);
    if (json['image_3'] != null) images.add(json['image_3']);

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
        locationDetail: json['location_detail']);
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
