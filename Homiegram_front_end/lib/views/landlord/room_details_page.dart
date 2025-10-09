import 'package:flutter/material.dart';
import 'package:homi_2/components/api_client.dart';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/models/room.dart';

class RoomDetailsPage extends StatefulWidget {
  final GetRooms room;

  const RoomDetailsPage({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
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

  @override
  Widget build(BuildContext context) {
    final hasImages =
        widget.room.images != null && widget.room.images!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Room: ${widget.room.roomName}",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Image Carousel
            SizedBox(
              height: 300,
              child: hasImages
                  ? Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: widget.room.images!.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final imageUrl = widget.room.images![index];
                            return BlurCachedImage(
                              imageUrl: '$devUrl$imageUrl',
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        // 🟢 Page Indicators
                        Positioned(
                          bottom: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.room.images!.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
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
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_not_supported,
                              size: 80, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            "No images available",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // 🏡 Room Details Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    detailRow("Room Name", widget.room.roomName),
                    detailRow("Bedrooms", "${widget.room.noOfBedrooms}"),
                    detailRow(
                        "Size", "${widget.room.sizeInSqMeters} sq. meters"),
                    detailRow("Rent", "Ksh ${widget.room.rentAmount}"),
                    detailRow(
                        "Occupied", widget.room.occuiedStatus ? 'Yes' : 'No'),
                    detailRow(
                        "Rent Paid", widget.room.rentStatus ? 'Yes' : 'No'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ✏️ Edit Button
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF105A01),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/edit-room',
                      arguments: widget.room);
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "Edit Room",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper for consistent details display
  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF105A01),
            ),
          ),
          Flexible(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
