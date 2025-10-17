class HouseRating {
  final int id;
  final int house;
  final int rating;
  final String? comment;

  HouseRating({
    required this.id,
    required this.house,
    required this.rating,
    this.comment,
  });

  factory HouseRating.fromJson(Map<String, dynamic> json) {
    return HouseRating(
      id: json['id'],
      house: json['house'],
      rating: json['rating'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'house': house,
      'rating': rating,
      'comment': comment,
    };
  }
}
