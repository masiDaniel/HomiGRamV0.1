import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;
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

      // Optionally upload to server here and get a new URL, then store it.
      // Example (pseudo):
      // String newUrl = await uploadImageToServer(File(picked.path));
      // setState(() => uploadedImageUrl = newUrl);
    }
  }

  Future<void> saveRoomDetails() async {
    String? token = await UserPreferences.getAuthToken();
    final uri = Uri.parse("$devUrl/houses/updateRoom/${widget.room.roomId}/");

    var request = http.MultipartRequest("PATCH", uri);

    // Add form fields

    request.fields['room_name'] = nameController.text;
    request.fields['number_of_bedrooms'] = bedroomsController.text;
    request.fields['size_in_sq_meters'] = sizeController.text;
    request.fields['rent'] = rentController.text;
    request.fields['apartment'] = widget.room.apartmentID.toString();

    // Add image file if selected
    if (selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('room_images', selectedImage!.path),
      );
    }

    // Add authorization if needed
    request.headers['Authorization'] = 'Token $token';

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        final updatedJson = json.decode(responseBody);

        final updatedRoom = GetRooms.fromJSon(updatedJson);
        if (!mounted) return;
        Navigator.pop(context, updatedRoom);
      } else {}
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
          children: [
            // Display image preview
            hasImage
                ? selectedImage != null
                    ? Image.file(selectedImage!, height: 200)
                    : Image.network(widget.room.roomImages, height: 200)
                : const Placeholder(fallbackHeight: 200),

            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Change Image"),
            ),

            const SizedBox(height: 20),

            // Input fields
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Room Name"),
            ),
            TextField(
              controller: bedroomsController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Number of Bedrooms"),
            ),
            TextField(
              controller: sizeController,
              decoration:
                  const InputDecoration(labelText: "Size in Sq. Meters"),
            ),
            TextField(
              controller: rentController,
              decoration: const InputDecoration(labelText: "Rent Amount"),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveRoomDetails,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
