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
      appBar: AppBar(title: Text(room.roomName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRoomPage(room: room),
                  ),
                );
              },
              child: const Text("Edit Room"),
            )
          ],
        ),
      ),
    );
  }
}
