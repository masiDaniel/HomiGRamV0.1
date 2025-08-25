import 'package:flutter/material.dart';
import 'package:homi_2/components/action_button.dart';
import 'package:homi_2/models/room.dart';
import 'package:homi_2/services/get_rooms_service.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:lottie/lottie.dart';

class RentingPage extends StatefulWidget {
  const RentingPage({super.key});

  @override
  State<RentingPage> createState() => _RentingPageState();
}

class _RentingPageState extends State<RentingPage> {
  late Future<List<GetRooms>> futureRooms;
  int? userId;

  @override
  void initState() {
    super.initState();
    futureRooms = fetchRooms();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    int? id = await UserPreferences.getUserId();
    setState(() {
      userId = id ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'My Renting Space',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.flag_circle_rounded,
              color: Color(0xFF126E06),
              size: 30,
            ),
          )
        ],
      ),
      body: FutureBuilder<List<GetRooms>>(
        future: futureRooms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Lottie.asset(
                'assets/animations/notFound.json',
                width: 200,
                height: 200,
              ),
            );
          } else if (snapshot.hasData) {
            List<GetRooms>? rooms = snapshot.data;
            List<GetRooms> matchedRooms =
                rooms!.where((room) => room.tenantId == userId).toList();

            if (matchedRooms.isEmpty) {
              return _buildNoRoomFound();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matchedRooms.length,
              itemBuilder: (context, index) {
                final room = matchedRooms[index];
                String imageUrl = '$devUrl${room.roomImages}';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'Image not available',
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    room.roomName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Chip(
                                      label: Text(
                                        room.rentStatus ? "Paid" : "Pending",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: room.rentStatus
                                          ? Colors.green
                                          : const Color(0xFF940B01),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.bed,
                                          color: Color(0xFF126E06)),
                                      const SizedBox(width: 6),
                                      Text("${room.noOfBedrooms} Bedrooms"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.monetization_on,
                                          color: Color(0xFF126E06)),
                                      const SizedBox(width: 6),
                                      Text(
                                        room.rentAmount,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: const Color(0xFF126E06),
                                      elevation: 0,
                                      side: const BorderSide(
                                          color: Color(0xFF126E06), width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    icon: const Icon(Icons.payments_rounded),
                                    label: const Text(
                                      "Pay Rent",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      ActionButton(
                                        label: "Raise Complaint",
                                        icon: Icons.report_problem,
                                        backgroundColor:
                                            const Color(0xFFF0B803),
                                        onPressed: () {},
                                      ),
                                      const SizedBox(width: 12),
                                      ActionButton(
                                        label: "Terminate",
                                        icon: Icons.cancel,
                                        backgroundColor:
                                            const Color(0xFF940B01),
                                        onPressed: () {
                                          _confirmTermination(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ]),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No rooms available"));
          }
        },
      ),
    );
  }

  Widget _buildNoRoomFound() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 100, color: Color(0xFF126E06)),
            SizedBox(height: 20),
            Text(
              "You don’t have a room assigned yet.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              "Head over to the search page to find your ideal room and unlock all renting services!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmTermination(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Confirm Termination",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
            "Are you sure you want to terminate your contract? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF940B01),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Continue", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
