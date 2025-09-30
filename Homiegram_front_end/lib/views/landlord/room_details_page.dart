import 'package:flutter/material.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/views/landlord/edit_room_page.dart';

const devUrl = AppConstants.baseUrl;

class RoomDetailsPage extends StatelessWidget {
  final GetRooms room;

  const RoomDetailsPage({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ROOM : ${room.roomName}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // TODO : have this in a better style
          children: [
            // Room Image

            room.roomImages.isNotEmpty
                ? Image.network('$devUrl${room.roomImages}')
                : const Placeholder(
                    fallbackHeight: 200,
                    fallbackWidth: double.infinity,
                  ),

            const SizedBox(height: 16),

            // Room Details
            Text("Room Name: ${room.roomName}",
                style: const TextStyle(fontSize: 16)),
            Text("Bedrooms: ${room.noOfBedrooms}"),
            Text("Size: ${room.sizeInSqMeters} sq. meters"),
            Text("Rent: ${room.rentAmount}"),
            Text("Occupied: ${room.occuiedStatus ? 'Yes' : 'No'}"),
            Text("Tenant ID: ${room.tenantId}"),
            Text("Rent Paid: ${room.rentStatus ? 'Yes' : 'No'}"),
            Text("Apartment ID: ${room.apartmentID}"),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF105A01),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRoomPage(room: room),
                  ),
                );
              },
              child: const Text(
                "Edit Room",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
