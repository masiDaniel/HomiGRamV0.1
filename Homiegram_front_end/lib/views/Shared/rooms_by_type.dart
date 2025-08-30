import 'package:flutter/material.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:homi_2/views/Tenants/rent_specific_room.dart';

class RoomsByTypePage extends StatefulWidget {
  final int houseId;
  final String bedroomCount;
  final List<GetRooms> rooms;

  const RoomsByTypePage({
    Key? key,
    required this.houseId,
    required this.bedroomCount,
    required this.rooms,
  }) : super(key: key);

  @override
  _RoomsByTypePageState createState() => _RoomsByTypePageState();
}

class _RoomsByTypePageState extends State<RoomsByTypePage> {
  List<GetRooms> filteredRooms = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredRooms = widget.rooms;
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredRooms = widget.rooms
          .where((room) =>
              room.roomName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bedroomCount} Bedroom Rooms'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: updateSearch,
              decoration: InputDecoration(
                hintText: 'Search rooms...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredRooms.isEmpty
                ? const Center(child: Text('No rooms found'))
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoomDetailsScreen(room: room),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: room.roomImages != null
                                    ? Image.network(
                                        '$devUrl${room.roomImages}',
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      room.roomName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Rent: ${room.rentAmount}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      room.occuiedStatus
                                          ? 'Occupied'
                                          : 'Available',
                                      style: TextStyle(
                                          color: room.occuiedStatus
                                              ? Colors.red
                                              : Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
