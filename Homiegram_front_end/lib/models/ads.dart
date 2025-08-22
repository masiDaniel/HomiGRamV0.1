class Ad {
  late String title;
  late String description;
  final String? imageUrl;
  final String? videoUrl;
  final String startDate;
  final String endDate;

  Ad(
      {this.imageUrl,
      this.videoUrl,
      required this.title,
      required this.description,
      required this.startDate,
      required this.endDate});

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
        // handling null was very problematic
        imageUrl: json['image']?.toString(),
        videoUrl: json['video_file']?.toString(),
        title: json['title'] as String,
        description: json['description'] as String,
        startDate: json['start_date'],
        endDate: json['end_date']);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': imageUrl,
      'video_file': videoUrl,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}

class AdRequest {
  final String? title;
  final String? description;
  final String? startDate;
  final String? endDate;

  AdRequest(
      {this.title,
      this.description,
      this.startDate,
      this.endDate,
      String? message});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_date': startDate, // Ensures it's properly formatted
      'end_date': endDate,
    };
  }

  factory AdRequest.fromJson(Map<String, dynamic> json) {
    return AdRequest(
      message: json['message'] as String?,
    );
  }
}
