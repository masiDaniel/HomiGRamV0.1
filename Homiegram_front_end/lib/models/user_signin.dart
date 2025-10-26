class UserRegistration {
  final String? email;
  final String? password;

  UserRegistration({this.email, this.password});

  factory UserRegistration.fromJSon(Map<String, dynamic> json) {
    return UserRegistration(
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> tojson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
