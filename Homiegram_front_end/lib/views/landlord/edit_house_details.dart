import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homi_2/components/my_snackbar.dart';
// import 'package:homi_2/models/amenities.dart';
// import 'package:homi_2/services/get_amenities.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:image_picker/image_picker.dart';

class EditHouseDetailsPage extends StatefulWidget {
  final GetHouse house;
  const EditHouseDetailsPage({super.key, required this.house});

  @override
  State<EditHouseDetailsPage> createState() => _EditHouseDetailsPageState();
}

class _EditHouseDetailsPageState extends State<EditHouseDetailsPage> {
  bool isEditing = false;
  bool isLoading = true;

  String houseName = '';
  String rentAmount = '';
  String description = '';
  String bankName = '';
  String accountNumber = '';

  late TextEditingController houseNameController;
  late TextEditingController rentAmountController;
  late TextEditingController descriptionController;
  late TextEditingController bankNameController;
  late TextEditingController accountNumberController;
  // List<Amenities> amenities = [];
  // List<Amenities> selectedAmenities = [];
  // late Future<List<Amenities>> futureAmenities;

  // Track selected amenities
  late Set<int> selectedAmenities;

  // Example available amenities
  final Map<int, String> allAmenities = {
    1: "Wi-Fi",
    2: "Parking",
    3: "Water",
    4: "Security",
    5: "Laundry",
  };
// images
  final ImagePicker _picker = ImagePicker();
  final List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();

    houseNameController = TextEditingController(text: widget.house.name);
    rentAmountController =
        TextEditingController(text: widget.house.rentAmount.toString());
    descriptionController =
        TextEditingController(text: widget.house.description);
    bankNameController = TextEditingController(text: widget.house.bankName);
    accountNumberController =
        TextEditingController(text: widget.house.accountNumber);

    // ignore: unnecessary_null_comparison
    selectedAmenities = widget.house.amenities != null
        ? Set<int>.from(widget.house.amenities)
        : <int>{};

    isLoading = false;
  }

  Future<void> _saveChanges() async {
    houseName = houseNameController.text;
    rentAmount = rentAmountController.text;
    description = descriptionController.text;
    bankName = bankNameController.text;
    accountNumber = accountNumberController.text;

    final updatedData = {
      'name': houseName,
      'rent_amount': rentAmount,
      'description': description,
      'payment_bank_name': bankName,
      'payment_account_number': accountNumber,
      // 'amenities': selectedAmenities.toList(),
      'images': _imageUrls
    };

    await updateHouseInfo(updatedData, widget.house.houseId);
    if (!mounted) return;
    showCustomSnackBar(context, 'House details updated!');
  }

  Future<void> _pickImages() async {
    if (_imageUrls.length >= 4) {
      showCustomSnackBar(context, 'You can only select up to 4 images.');
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage();

    final int remainingSlots = 4 - _imageUrls.length;

    setState(() {
      _imageUrls.addAll(
        images.take(remainingSlots).map((file) => file.path),
      );
    });

    if (!mounted) return;

    if (images.length > remainingSlots) {
      showCustomSnackBar(
          context, 'Some images were not added due to the 4-image limit.');
    }
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

  // Widget _buildAmenitiesSection() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text('Amenities',
  //             style: TextStyle(fontWeight: FontWeight.bold)),
  //         ...allAmenities.entries.map((entry) {
  //           return CheckboxListTile(
  //             title: Text(entry.value),
  //             value: selectedAmenities.contains(entry.key),
  //             onChanged: isEditing
  //                 ? (bool? value) {
  //                     setState(() {
  //                       if (value == true) {
  //                         selectedAmenities.add(entry.key);
  //                       } else {
  //                         selectedAmenities.remove(entry.key);
  //                       }
  //                     });
  //                   }
  //                 : null,
  //           );
  //         }).toList(),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit House Details'),
        actions: [
          TextButton(
            onPressed: toggleEdit,
            child: Text(
              isEditing ? 'Save' : 'Edit',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildField('House Name', houseNameController),
            _buildField('Rent Amount', rentAmountController),
            _buildField('Description', descriptionController),
            _buildField('Bank Name', bankNameController),
            _buildField('Account Number', accountNumberController),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF105A01),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _pickImages,
              child: const Text(
                'Select Images',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            _imageUrls.isNotEmpty
                ? Wrap(
                    spacing: 8.0,
                    children: _imageUrls.take(4).map((url) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            File(url),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _imageUrls.remove(url);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  )
                : const Center(child: Text('No images selected.')),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            // _buildAmenitiesSection(),
          ],
        ),
      ),
    );
  }
}
