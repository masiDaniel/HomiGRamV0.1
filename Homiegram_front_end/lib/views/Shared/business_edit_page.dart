import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/models/business.dart';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/services/business_services.dart';
import 'package:homi_2/services/get_locations.dart';
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

  int? selectedLocation;
  int? selectedBusinessType;

  late BusinessModel originalData;
  List<Category> categories = [];
  List<Locations> locations = [];
  bool isLoading = true;

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

    fetchCategories();
    _loadLocations();
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await fetchCategorys();
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadLocations() async {
    final fetchedLocations = await fetchLocations();

    setState(() {
      locations = fetchedLocations;
      isLoading = false;
    });
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
      updates['location'] = selectedLocation;
    }
    if (selectedBusinessType != originalData.businessTypeId) {
      updates['business_type'] = selectedBusinessType;
    }

    if (businessImageController.text != originalData.businessImage) {
      updates['business_image'] = businessImageController.text;
    }

    if (updates.isEmpty) {
      showCustomSnackBar(context, "No Changes to update");
      return;
    }

    final url = Uri.parse(
        '$devUrl/business/updateBusiness/${widget.business.businessId}/');
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
    if (response.statusCode == 202) {
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
              decoration: const InputDecoration(labelText: "Location"),
              items: locations.isNotEmpty
                  ? locations.map((location) {
                      return DropdownMenuItem(
                        value: location.locationId,
                        child: Text(
                            "${location.county}, ${location.town}, ${location.area}"),
                      );
                    }).toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
            ),
            DropdownButtonFormField<int>(
              value: selectedBusinessType,
              decoration: const InputDecoration(labelText: "Category"),
              items: categories.isNotEmpty
                  ? categories.map((category) {
                      return DropdownMenuItem(
                        value: category.categoryId,
                        child: Text(category.categoryName),
                      );
                    }).toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  selectedBusinessType = value;
                });
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
