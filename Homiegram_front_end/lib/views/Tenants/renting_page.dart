import 'package:flutter/material.dart';
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

/// TODO : have alll the tools a tenant will need in regards to their unit
/// - paying rent
/// - rasing and viewing tickets
/// - terminating lease.

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
        title: const Text('Renting Page'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.flag_circle_sharp,
              color: Color(0xFF126E06),
              size: 30,
            ),
          )
        ],
      ),
      body: FutureBuilder<List<GetRooms>>(
        future: fetchRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Lottie.asset(
                'assets/animations/notFound.json',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            );
          } else if (snapshot.hasData) {
            List<GetRooms>? rooms = snapshot.data;

            List<GetRooms> matchedRooms =
                rooms!.where((room) => room.tenantId == userId).toList();

            if (matchedRooms.isEmpty) {
              // No room found for the current user
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, size: 100, color: Color(0xFF126E06)),
                      SizedBox(height: 20),
                      Text(
                        'You don\'t have a room assigned yet.',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Get a room now to access this service and enjoy seamless experience!\nHead over to the search page for multiple choices!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            } else {
              // Room found for the current user

              return ListView.builder(
                itemCount: matchedRooms.length,
                itemBuilder: (context, index) {
                  String imageUrl = '$devUrl${matchedRooms[index].roomImages}';
                  bool rentStatus = matchedRooms[index].rentStatus;

                  return Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Container(
                          //   height:
                          //       250, // Adjust the height based on your needs
                          //   width: double.infinity,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(15.0),
                          //     boxShadow: const [
                          //       BoxShadow(
                          //         color: Color(0xFF0C6601),
                          //         // spreadRadius: 3,
                          //         // blurRadius: 5,
                          //         // offset: Offset(0, 3),
                          //       ),
                          //     ],
                          //   ),
                          //   child: ClipRRect(
                          //     borderRadius: BorderRadius.circular(15.0),
                          //     child: Image.network(
                          //       imageUrl,
                          //       fit: BoxFit.cover,
                          //       loadingBuilder:
                          //           (context, child, loadingProgress) {
                          //         if (loadingProgress == null) return child;
                          //         return Center(
                          //           child: CircularProgressIndicator(
                          //             value:
                          //                 loadingProgress.expectedTotalBytes !=
                          //                         null
                          //                     ? loadingProgress
                          //                             .cumulativeBytesLoaded /
                          //                         (loadingProgress
                          //                                 .expectedTotalBytes ??
                          //                             1)
                          //                     : null,
                          //           ),
                          //         );
                          //       },
                          //       errorBuilder: (context, error, stackTrace) {
                          //         return const Center(
                          //             child: Text(
                          //           'Image not available',
                          //           style: TextStyle(color: Colors.white),
                          //         ));
                          //       },
                          //     ),
                          //   ),
                          // ),

                          // Room ID
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.home,
                                color: Color(0xFF126E06)),
                            title: const Text(
                              'Room Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(matchedRooms[index].roomName),
                          ),
                          const Divider(),

                          // Bedrooms Section
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading:
                                const Icon(Icons.bed, color: Color(0xFF126E06)),
                            title: const Text(
                              'Bedrooms',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle:
                                Text('${matchedRooms[index].noOfBedrooms}'),
                          ),
                          const Divider(),

                          // Rent Amount Section
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.monetization_on,
                                color: Color(0xFF126E06)),
                            title: const Text(
                              'Rent Amount',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(matchedRooms[index].rentAmount),
                          ),
                          const Divider(),

                          // Rent Status Section
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.payments,
                                color: Color(0xFF126E06)),
                            title: const Text(
                              'Rent Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text('${matchedRooms[index].rentStatus}'),
                          ),

                          const Divider(),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 240, 184, 3),
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {},
                                child: const ListTile(
                                  title: Text('Raise Complaint'),
                                ),
                              ),
                            ),
                          ),
                          const Divider(),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFF940B01),
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Are you sure?'),
                                        content: const Text(
                                            'Do you really want to terminate the contract? This action cannot be undone.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Color(0xFF014901),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF940B01)),
                                            child: const Text(
                                              'Continue',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const ListTile(
                                  title: Text('Terminate contract'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            return const Center(child: Text('No rooms available'));
          }
        },
      ),
    );
  }
}
