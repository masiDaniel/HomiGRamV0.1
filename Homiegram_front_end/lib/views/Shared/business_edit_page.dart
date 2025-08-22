import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/models/business.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;

class BusinessEditPage extends StatefulWidget {
  final BusinessModel business;

  const BusinessEditPage({super.key, required this.business});

  @override
  State<BusinessEditPage> createState() => _BusinessEditPageState();
}

class _BusinessEditPageState extends State<BusinessEditPage> {
  late TextEditingController businessNameController;
  late TextEditingController contactNumberController;
  late TextEditingController businessEmailController;
  late TextEditingController businessAddressController;
  late TextEditingController businessOwnerIdController;
  late TextEditingController businessTypeIdController;
  late TextEditingController businessImageController;

  late int selectedLocation;
  late int selectedBusinessType;

  late BusinessModel originalData;

  @override
  void initState() {
    super.initState();

    originalData = widget.business;

    businessNameController =
        TextEditingController(text: widget.business.businessName);
    contactNumberController =
        TextEditingController(text: widget.business.contactNumber);
    businessEmailController =
        TextEditingController(text: widget.business.businessEmail);
    businessAddressController =
        TextEditingController(text: widget.business.businessAddress.toString());
    businessOwnerIdController =
        TextEditingController(text: widget.business.businessOwnerId.toString());
    businessTypeIdController =
        TextEditingController(text: widget.business.businessTypeId.toString());
    businessImageController =
        TextEditingController(text: widget.business.businessImage);

    selectedLocation = widget.business.businessAddress;
    selectedBusinessType = widget.business.businessTypeId;
  }

  Future<void> updateBusiness() async {
    Map<String, dynamic> updates = {};

    if (businessNameController.text != originalData.businessName) {
      updates['business_name'] = businessNameController.text;
    }
    if (contactNumberController.text != originalData.contactNumber) {
      updates['contact_number'] = contactNumberController.text;
    }
    if (businessEmailController.text != originalData.businessEmail) {
      updates['business_email'] = businessEmailController.text;
    }
    if (selectedLocation != originalData.businessAddress) {
      updates['business_address'] = selectedLocation;
    }
    if (selectedBusinessType != originalData.businessTypeId) {
      updates['business_type_id'] = selectedBusinessType;
    }
    if (businessTypeIdController.text !=
        originalData.businessTypeId.toString()) {
      updates['business_type_id'] = int.tryParse(businessTypeIdController.text);
    }
    if (businessImageController.text != originalData.businessImage) {
      updates['business_image'] = businessImageController.text;
    }

    if (updates.isEmpty) {
      showCustomSnackBar(context, "No Changes to update");
      return;
    }

    final url = Uri.parse(
        '$devUrl/business/updateBusiness/${widget.business.businessId}');
    String? token = await UserPreferences.getAuthToken();

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(updates),
    );

    if (!mounted) return;
    if (response.statusCode == 200) {
      showCustomSnackBar(context, "Business updated successfully");
    } else {
      showCustomSnackBar(context, "Update failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Business")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: businessNameController,
              decoration: const InputDecoration(labelText: 'Business Name'),
            ),
            TextFormField(
              controller: contactNumberController,
              decoration: const InputDecoration(labelText: 'Contact Number'),
            ),
            TextFormField(
              controller: businessEmailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedLocation,
              decoration: const InputDecoration(labelText: 'Location'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Location 1')),
                DropdownMenuItem(value: 2, child: Text('Location 2')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedLocation = value;
                  });
                }
              },
            ),
            DropdownButtonFormField<int>(
              value: selectedBusinessType,
              decoration: const InputDecoration(labelText: 'Business Type'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Retail')),
                DropdownMenuItem(value: 2, child: Text('Wholesale')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedBusinessType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: updateBusiness,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
