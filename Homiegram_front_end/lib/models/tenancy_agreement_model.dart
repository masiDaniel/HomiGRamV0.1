class Agreement {
  final int id;
  final String startDate;
  final String? endDate;
  final String status;
  final bool terminationRequested;
  final String tenant;
  final String house;
  final String room;

  Agreement({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.terminationRequested,
    required this.tenant,
    required this.house,
    required this.room,
  });

  factory Agreement.fromJson(Map<String, dynamic> json) {
    return Agreement(
      id: json['id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      status: json['status'] ?? '',
      terminationRequested: json['termination_requested'] ?? false,
      tenant: json['tenant'] ?? 0,
      house: json['house'] ?? 0,
      room: json['room'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "start_date": startDate,
      "end_date": endDate,
      "status": status,
      "termination_requested": terminationRequested,
      "tenant": tenant,
      "house": house,
      "room": room,
    };
  }
}
