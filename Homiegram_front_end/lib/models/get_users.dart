class GerUsers {
  final String? email;
  final String? firstName;
  final String? lastName;
  final int? userId;
  final String? phoneNumber;

  GerUsers(
      {this.email,
      this.firstName,
      this.lastName,
      this.userId,
      this.phoneNumber});

  factory GerUsers.fromJSon(Map<String, dynamic> json) {
    return GerUsers(
        email: json['email'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        userId: json['id'],
        phoneNumber: json['phone_number']);
  }
}
