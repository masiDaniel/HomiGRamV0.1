import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'nickName';
  static const String _keyFirstName = 'firstName';
  static const String _keyLastName = 'lastName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserType = 'userType';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyPhoneNumber = 'phoneNumber';
  static const String _keyIdNumber = 'idNumber';
  static const String _keyProfilePic = 'profilePicture';

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyUserId, userData['id']);
    await prefs.setString(_keyUserName, userData['nick_name'] ?? 'Homie');
    await prefs.setString(_keyFirstName, userData['first_name']);
    await prefs.setString(_keyLastName, userData['last_name']);
    await prefs.setString(_keyUserEmail, userData['email']);
    await prefs.setString(_keyUserType, userData['user_type']);
    await prefs.setString(_keyPhoneNumber, userData['phone_number']);
    await prefs.setInt(_keyIdNumber, userData['id_number']);
    await prefs.setString(_keyProfilePic, userData['profile_pic'] ?? 'N/A');
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> savePartialUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    if (userData.containsKey('nick_name')) {
      await prefs.setString(_keyUserName, userData['nick_name']);
    }
    if (userData.containsKey('first_name')) {
      await prefs.setString(_keyFirstName, userData['first_name']);
    }
    if (userData.containsKey('last_name')) {
      await prefs.setString(_keyLastName, userData['last_name']);
    }
    if (userData.containsKey('email')) {
      await prefs.setString(_keyUserEmail, userData['email']);
    }
    if (userData.containsKey('phone_number')) {
      await prefs.setString(_keyPhoneNumber, userData['phone_number']);
    }
    if (userData.containsKey('id_number')) {
      await prefs.setInt(_keyIdNumber, userData['id_number']);
    }
    if (userData.containsKey('user_type')) {
      await prefs.setString(_keyUserType, userData['user_type']);
    }
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getInt(_keyUserId),
      'nick_name': prefs.getString(_keyUserName),
      'first_name': prefs.getString(_keyFirstName),
      'last_name': prefs.getString(_keyLastName),
      'email': prefs.getString(_keyUserEmail),
      'user_type': prefs.getString(_keyUserType),
      'phone_number': prefs.getString(_keyPhoneNumber),
      'id_number': prefs.getInt(_keyIdNumber),
      'profile_pic': prefs.getString(_keyProfilePic),
      'is_logged_in': prefs.getBool(_keyIsLoggedIn) ?? false,
      'login_time': prefs.getInt('login_time'),
    };
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFirstName);
  }

  static Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastName);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserType);
  }

  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhoneNumber);
  }

  static Future<int?> getIdNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyIdNumber);
  }

  static Future<String?> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfilePic);
  }

  static Future<bool> setProfilePicture(String path) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyProfilePic, path);
    return true;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }
}
