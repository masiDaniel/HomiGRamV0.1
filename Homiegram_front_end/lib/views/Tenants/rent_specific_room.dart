import 'package:flutter/material.dart';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/services/rent_room_service.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/views/Tenants/renting_flow_page.dart';

class RoomDetailsScreen extends StatefulWidget {
  final GetRooms room;

  const RoomDetailsScreen({super.key, required this.room});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    int currentPage = 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.room.images!.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentPage == index ? 12 : 8,
                    height: currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentPage == index ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ),
              background: SizedBox(
                  height: 500,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: widget.room.images!.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
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
                          ));
                    },
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
                    widget.room.roomName,
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
                      Text("${widget.room.noOfBedrooms} Bedroom(s)"),
                      const SizedBox(width: 20),
                      Icon(Icons.square_foot_outlined, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text("${widget.room.sizeInSqMeters} m²"),
                      const SizedBox(height: 6),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Rent: KES ${widget.room.rentAmount}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: widget.room.occuiedStatus
            ? null
            : SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    String? userTypeShared =
                        await UserPreferences.getUserType();

                    if (userTypeShared == "landlord") {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Landlords cannot rent rooms.'),
                            actions: [
                              TextButton(
                                style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Color(0x95154D07)),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RentFlowPage(
                                houseId: widget.room.apartmentID,
                                roomId: widget.room.roomId)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x95154D07),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Rent this room",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
