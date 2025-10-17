import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homi_2/components/blured_image.dart';
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
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.room.roomName);
    bedroomsController =
        TextEditingController(text: widget.room.noOfBedrooms.toString());
    sizeController = TextEditingController(text: widget.room.sizeInSqMeters);
    rentController = TextEditingController(text: widget.room.rentAmount);
    _pageController = PageController(initialPage: 0);
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
    } catch (e) {
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
    return Scaffold(
        appBar: AppBar(title: const Text("Edit Room")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 360,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      height: 500,
                      child: (widget.room.images == null ||
                              widget.room.images!.isEmpty)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_not_supported,
                                      size: 80, color: Colors.grey),
                                  const SizedBox(height: 10),
                                  Text(
                                    "No images available",
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : PageView.builder(
                              controller: _pageController,
                              itemCount: widget.room.images!.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final imageUrl = widget.room.images![index];

                                return SizedBox(
                                  width: double.infinity,
                                  child: BlurCachedImage(
                                    imageUrl: '$devUrl$imageUrl',
                                    height: 600,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                    ),
                    Positioned(
                      bottom: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.room.images!.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 12 : 8,
                            height: _currentPage == index ? 12 : 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
