import 'package:flutter/material.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/services/rent_room_service.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';

class RoomDetailsScreen extends StatelessWidget {
  final GetRooms room;

  const RoomDetailsScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(room.roomName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
              background: Expanded(
                  child: Image.network(
                '$devUrl${room.roomImages}',
                fit: BoxFit.cover,
              )),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.roomName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF126E06),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.bed_outlined, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text("${room.noOfBedrooms} Bedroom(s)"),
                      const SizedBox(width: 20),
                      Icon(Icons.square_foot_outlined, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text("${room.sizeInSqMeters} m²"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Rent: KES ${room.rentAmount}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(12),
          child: BottomAppBar(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      String? userTypeShared =
                          await UserPreferences.getUserType();

                      if (userTypeShared == "landlord") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content:
                                  const Text('Landlords cannot rent rooms.'),
                              actions: [
                                TextButton(
                                  style: const ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Color(0x95154D07)),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        String? message =
                            await rentRoom(room.apartmentID, room.roomId);

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(message == "Room successfully rented!"
                                  ? 'Success'
                                  : 'Error'),
                              content: Text(
                                  message ?? 'An unexpected error occurred.'),
                              actions: [
                                TextButton(
                                  style: const ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Color(0x95154D07)),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text("Rent",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x95154D07),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
