class Validators {
  static String? validatePassword(String password, {String? confirmPassword}) {
    final passwordRegex =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{6,}$');

    if (confirmPassword != null && password != confirmPassword) {
      return 'Passwords do not match';
    }

    if (!passwordRegex.hasMatch(password)) {
      return 'Password must have at least:\n'
          '- 1 uppercase letter\n'
          '- 1 lowercase letter\n'
          '- 1 number\n'
          '- 1 special character (!@#\$&*~)\n'
          '- 6+ characters';
    }

    return null;
  }
}
