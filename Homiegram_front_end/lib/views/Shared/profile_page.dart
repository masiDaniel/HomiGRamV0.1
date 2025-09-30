import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/services/theme_provider.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:homi_2/services/user_signout_service.dart';
import 'package:homi_2/views/Shared/bookmark_page.dart';
import 'package:homi_2/views/Shared/edit_profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const devUrl = AppConstants.baseUrl;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? currentUserType;
  int? currentUserId;
  String? currentUserFirstName;
  String? currentUserName;
  String? currentUserLastName;
  String? currentUserEmail;
  int? currentserIdNumber;
  String? currentUserPhoneNumber;
  String? currentUserProfilePicture;
  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  String extractInitials(String name) {
    if (name.isEmpty) {
      return 'HG';
    }
    List<String> nameParts = name.split(' ');
    if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    } else {
      return 'HG';
    }
  }

  Future<void> loadUserId() async {
    int? id = await UserPreferences.getUserId();
    String? type = await UserPreferences.getUserType();
    String? firstName = await UserPreferences.getFirstName();
    String? userName = await UserPreferences.getUserName();
    String? lastName = await UserPreferences.getLastName();
    String? email = await UserPreferences.getUserEmail();
    String? phoneNumber = await UserPreferences.getPhoneNumber();
    int? idNumber = await UserPreferences.getIdNumber();
    String? profilePicture = await UserPreferences.getProfilePicture();

    setState(() {
      currentUserId = id;
      currentUserType = type;
      currentUserFirstName = firstName;
      currentUserName = userName;
      currentUserLastName = lastName;
      currentUserEmail = email;
      currentUserPhoneNumber = phoneNumber;
      currentserIdNumber = idNumber;
      currentUserProfilePicture = profilePicture;
    });
  }

  Future<void> _logout() async {
    try {
      print("we get here");
      await logoutUser();
      print("we get here 1");

      await clearTokens();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userType');

      print("we get here 3");
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      log("Error logging out: $e");
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          currentUserProfilePicture = pickedFile.path;
        });
        if (!mounted) return;

        final bool? confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Update Profile Picture'),
              content:
                  const Text('Do you want to update your profile picture?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          await updateProfilePicture(currentUserProfilePicture!);
        }
      }
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, "Failed to select image. Try again later");
    }
  }

  void showFullImage() {
    if (currentUserProfilePicture != null &&
        currentUserProfilePicture!.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child:
              Image(image: NetworkImage(('$devUrl$currentUserProfilePicture'))),
        ),
      );
    }
  }

  ImageProvider<Object>? getProfileImage(
      String? profilePicture, String devUrl) {
    const defaultImage1 = AssetImage('assets/images/default_avatar.jpeg');

    if (profilePicture == null ||
        profilePicture.isEmpty ||
        profilePicture == "N/A") {
      return null;
    }

    if (profilePicture.startsWith("/media/")) {
      return NetworkImage('$devUrl$profilePicture');
    }

    final file = File(profilePicture);
    if (file.existsSync()) {
      return FileImage(file);
    }

    return defaultImage1;
  }

  @override
  Widget build(BuildContext context) {
    bool showInitials = currentUserProfilePicture == "N/A";
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: const Color(0xFF126E06),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Username',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$currentUserName'),
                        const SizedBox(height: 12),
                        const Text('Phone Number',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$currentUserPhoneNumber'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          /// TODO: View full profile picture
                          /// store and fetch the profie picture locally.
                        },
                        child: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 2, 75, 50),
                          radius: 50,
                          backgroundImage: getProfileImage(
                              currentUserProfilePicture, devUrl),
                          child: (currentUserProfilePicture == null ||
                                      currentUserProfilePicture!.isEmpty) &&
                                  showInitials
                              ? Text(
                                  extractInitials(currentUserFirstName ?? ''),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: pickImage,
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Color(0xFF126E06),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Second Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('First Name',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('$currentUserFirstName'),
                  const SizedBox(height: 12),
                  const Text('Last Name',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('$currentUserLastName'),
                  const SizedBox(height: 12),
                  const Text('Email',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('$currentUserEmail'),
                  const SizedBox(height: 12),
                  const Text('ID Number',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('$currentserIdNumber'),
                ],
              ),
            ),
          ),

          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Tools',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),

                  // Bookmarks
                  ListTile(
                    leading: const Icon(Icons.bookmark_add_outlined,
                        color: Color(0xFF126E06)),
                    title: const Text('Bookmarks'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookmarkedHousesPage(userId: currentUserId!),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.brightness_6_outlined,
                        color: Color(0xFF126E06)),
                    title: const Text('Theme'),
                    trailing: PopupMenuButton<ThemeMode>(
                      initialValue: themeProvider.themeMode,
                      onSelected: (ThemeMode mode) {
                        themeProvider.setThemeMode(mode);
                      },
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) {
                        ThemeMode currentTheme = themeProvider.themeMode;
                        return [
                          PopupMenuItem(
                            value: ThemeMode.system,
                            child: Row(
                              children: [
                                Icon(Icons.settings,
                                    color: currentTheme == ThemeMode.system
                                        ? Colors.green
                                        : Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  "System",
                                  style: TextStyle(
                                    fontWeight: currentTheme == ThemeMode.system
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: ThemeMode.light,
                            child: Row(
                              children: [
                                Icon(Icons.wb_sunny,
                                    color: currentTheme == ThemeMode.light
                                        ? Colors.orange
                                        : Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  "Light",
                                  style: TextStyle(
                                    fontWeight: currentTheme == ThemeMode.light
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: ThemeMode.dark,
                            child: Row(
                              children: [
                                Icon(Icons.nights_stay,
                                    color: currentTheme == ThemeMode.dark
                                        ? Colors.deepPurple
                                        : Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  "Dark",
                                  style: TextStyle(
                                    fontWeight: currentTheme == ThemeMode.dark
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              themeProvider.themeMode == ThemeMode.dark
                                  ? Icons.nights_stay
                                  : themeProvider.themeMode == ThemeMode.light
                                      ? Icons.wb_sunny
                                      : Icons.settings,
                              color: Colors.green[900],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _themeModeLabel(themeProvider.themeMode),
                              style: TextStyle(
                                color: Colors.green[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (currentUserType != "landlord")
            ElevatedButton.icon(
              onPressed: () async {
                Map<String, dynamic> updateData = {};
                updateData['user_type'] = 'landlord';
                bool? success = await updateUserInfo(updateData);
                if (success == true) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset('assets/animations/fix.json',
                              width: 200, height: 200),
                          const SizedBox(height: 20),
                          const Text(
                            "You are now a landlord with us!",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );

                  await Future.delayed(const Duration(seconds: 2));
                  Navigator.of(context).pop();
                  _logout();
                } else {
                  log('Failed to update profile.');
                }
              },
              icon: const Icon(
                Icons.house,
                color: Colors.white,
              ),
              label: const Text(
                'Become a Landlord',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 30, 100, 200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              _logout();
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 160, 2, 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "Light";
      case ThemeMode.dark:
        return "Dark";
      case ThemeMode.system:
        return "System";
    }
  }
}
