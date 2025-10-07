import 'package:flutter/material.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isEditing = false;
  bool isLoading = true;

  String nickName = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';

  late TextEditingController nickNameController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserPreferences.getUserData();

    setState(() {
      nickName = userData['nick_name'] ?? '';
      firstName = userData['first_name'] ?? '';
      lastName = userData['last_name'] ?? '';
      email = userData['email'] ?? '';
      phoneNumber = userData['phone_number'] ?? '';

      nickNameController = TextEditingController(text: nickName);
      firstNameController = TextEditingController(text: firstName);
      lastNameController = TextEditingController(text: lastName);
      emailController = TextEditingController(text: email);
      phoneNumberController = TextEditingController(text: phoneNumber);

      isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    final newNickName = nickNameController.text;
    final newFirstName = firstNameController.text;
    final newLastName = lastNameController.text;
    final newEmail = emailController.text;
    final newPhoneNumber = phoneNumberController.text;

    final updatedData = {
      'nick_name': newNickName,
      'first_name': newFirstName,
      'last_name': newLastName,
      'email': newEmail,
      'phone_number': newPhoneNumber,
    };

    final hasChanged = newNickName != nickName ||
        newFirstName != firstName ||
        newLastName != lastName ||
        newEmail != email ||
        newPhoneNumber != phoneNumber;

    if (!hasChanged) {
      if (!mounted) return;
      showCustomSnackBar(context, 'No changes to save.');
      return;
    }

    await updateUserInfo(updatedData);
    await UserPreferences.savePartialUserData(updatedData);

    if (!mounted) return;
    showCustomSnackBar(context, 'Profile updated!');
  }

  void toggleEdit() {
    setState(() {
      if (isEditing) {
        _saveChanges();
      }
      isEditing = !isEditing;
    });
  }

  Widget _buildField(String label, TextEditingController controller) {
    return isEditing
        ? TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
          )
        : ListTile(
            title: Text(label),
            subtitle: Text(controller.text),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: toggleEdit,
            child: Text(
              isEditing ? 'Save' : 'Edit',
              style: const TextStyle(color: Color(0xFF126E06)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildField('Nickname', nickNameController),
            _buildField('First Name', firstNameController),
            _buildField('Last Name', lastNameController),
            _buildField('Email', emailController),
            _buildField('Phone Number', phoneNumberController),
          ],
        ),
      ),
    );
  }
}
