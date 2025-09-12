class Amenities {
  final int? id;
  final String? name;

  Amenities({
    this.id,
    this.name,
  });

  factory Amenities.fromJSon(Map<String, dynamic> json) {
    return Amenities(
      id: json['id'],
      name: json['name'],
    );
  }
}
