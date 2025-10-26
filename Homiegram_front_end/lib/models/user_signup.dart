class UserSignUp {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;

  const UserSignUp({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
  });

  factory UserSignUp.fromJSon(Map<String, dynamic> json) {
    return UserSignUp(
      firstName: json['first_name'],
      lastName: json['last-Name'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password
    };
  }
}
