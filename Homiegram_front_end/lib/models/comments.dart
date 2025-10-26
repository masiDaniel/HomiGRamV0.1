class GetComments {
  final int commentId;
  final int houseId;
  final int userId;
  final String comment;
  final int? parent;
  final int likes;
  final int dislikes;

  GetComments(
      {required this.commentId,
      required this.houseId,
      required this.userId,
      required this.comment,
      this.parent,
      required this.likes,
      required this.dislikes});

  factory GetComments.fromJSon(Map<String, dynamic> json) {
    return GetComments(
      commentId: json['id'] ?? 0,
      houseId: json['house_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      comment: json['comment'] ?? '',
      parent: json['parent'],
      likes: json['total_likes'] ?? 0,
      dislikes: json['total_dislikes'] ?? 0,
    );
  }

  Map<String, dynamic> tojson() {
    return {
      "id": commentId,
      "house_id": houseId,
      "user_id": userId,
      "comment": comment,
    };
  }
}
