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

  // Fields to be edited
  String nickName = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  // int idNumber = 0;

  // Controllers
  late TextEditingController nickNameController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  // late TextEditingController IDNumberController;

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
      // idNumber = userData['id_number'] ?? '';

      // Initialize controllers
      nickNameController = TextEditingController(text: nickName);
      firstNameController = TextEditingController(text: firstName);
      lastNameController = TextEditingController(text: lastName);
      emailController = TextEditingController(text: email);
      phoneNumberController = TextEditingController(text: phoneNumber);
      // IDNumberController = TextEditingController(text: idNumber);

      isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    // Update values from controllers
    nickName = nickNameController.text;
    firstName = firstNameController.text;
    lastName = lastNameController.text;
    email = emailController.text;
    phoneNumber = phoneNumberController.text;
    // idNumber = IDNumberController.text;

    final updatedData = {
      'nick_name': nickName,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      // 'id_number': idNumber
    };
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
            // _buildField('ID Number', IDNumberController),
          ],
        ),
      ),
    );
  }
}
