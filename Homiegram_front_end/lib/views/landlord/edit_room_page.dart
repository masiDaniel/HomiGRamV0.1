import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/services/house_service.dart';
import 'package:image_picker/image_picker.dart';

class EditRoomPage extends StatefulWidget {
  final GetRooms room;

  const EditRoomPage({Key? key, required this.room}) : super(key: key);

  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  late TextEditingController nameController;
  late TextEditingController bedroomsController;
  late TextEditingController sizeController;
  late TextEditingController rentController;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.room.roomName);
    bedroomsController =
        TextEditingController(text: widget.room.noOfBedrooms.toString());
    sizeController = TextEditingController(text: widget.room.sizeInSqMeters);
    rentController = TextEditingController(text: widget.room.rentAmount);
  }

  @override
  void dispose() {
    nameController.dispose();
    bedroomsController.dispose();
    sizeController.dispose();
    rentController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> saveRoomDetails() async {
    try {
      final updatedRoom = await HouseService.updateRoom(
        roomId: widget.room.roomId,
        roomName: nameController.text,
        numberOfBedrooms: bedroomsController.text,
        sizeInSqMeters: sizeController.text,
        rent: rentController.text,
        apartmentId: widget.room.apartmentID,
        imagePath: selectedImage?.path,
      );

      if (!mounted) return;
      Navigator.pop(context, updatedRoom);
    } catch (e, stackTrace) {
      debugPrint("Error saving room details: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save room details. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = selectedImage != null || widget.room.roomImages.isNotEmpty;

    return Scaffold(
        appBar: AppBar(title: const Text("Edit Room")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📸 Image Preview Section
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: hasImage
                    ? selectedImage != null
                        ? Image.file(
                            selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            widget.room.roomImages,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                    : Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFF126E06), width: 1),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 60,
                            color: Color(0xFF126E06),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(
                  Icons.image_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  "Change Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF126E06),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),

              const SizedBox(height: 24),

              // 🏠 Input Fields
              _buildTextField(nameController, "Room Name"),
              const SizedBox(height: 16),
              _buildTextField(
                bedroomsController,
                "Number of Bedrooms",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(sizeController, "Size in Sq. Meters"),
              const SizedBox(height: 16),
              _buildTextField(rentController, "Rent Amount"),
              const SizedBox(height: 24),

              // 💾 Save Button
              ElevatedButton(
                onPressed: saveRoomDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF105A01),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF105A01)),
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF126E06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF105A01), width: 2),
        ),
      ),
      cursorColor: const Color(0xFF105A01),
    );
  }
}
