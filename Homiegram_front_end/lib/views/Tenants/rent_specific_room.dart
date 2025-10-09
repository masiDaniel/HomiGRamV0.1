import 'package:flutter/material.dart';
import 'package:homi_2/components/api_client.dart';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/views/Tenants/renting_flow_page.dart';

class RoomDetailsScreen extends StatefulWidget {
  final GetRooms room;

  const RoomDetailsScreen({super.key, required this.room});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF126E06), size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Room Details",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.room.roomName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 7, 180, 15)
                              .withValues(alpha: 0.15),
                        ),
                      ],
                    ),
                    child: isSmallScreen
                        ? Column(
                            children: [
                              _infoItem(Icons.bed_outlined,
                                  "${widget.room.noOfBedrooms}", "Bedroom(s)"),
                              const Divider(),
                              _infoItem(Icons.square_foot_outlined,
                                  widget.room.sizeInSqMeters, "m²"),
                              const Divider(),
                              _infoItem(
                                  Icons.attach_money_rounded,
                                  "KES ${widget.room.rentAmount}",
                                  "Monthly Rent"),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _infoItem(Icons.bed_outlined,
                                  "${widget.room.noOfBedrooms}", "Bedroom(s)"),
                              Container(
                                height: 40,
                                width: 1.2,
                                color: Colors.grey.shade300,
                              ),
                              _infoItem(Icons.square_foot_outlined,
                                  "${widget.room.sizeInSqMeters}", "m²"),
                              Container(
                                height: 40,
                                width: 1.2,
                                color: Colors.grey.shade300,
                              ),
                              _infoItem(
                                  Icons.attach_money_rounded,
                                  "KES ${widget.room.rentAmount}",
                                  "Monthly Rent"),
                            ],
                          ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.room.occuiedStatus
            ? Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "This room is currently occupied",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              )
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
                            roomId: widget.room.roomId,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF126E06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
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
