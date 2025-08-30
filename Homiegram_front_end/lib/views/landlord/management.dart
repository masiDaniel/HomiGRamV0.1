import 'dart:developer';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/services/get_house_service.dart';
import 'package:homi_2/services/get_locations.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:homi_2/views/landlord/landlord_house_details.dart';
import 'package:homi_2/views/landlord/add_house.dart';
import 'package:lottie/lottie.dart';

class LandlordManagement extends StatefulWidget {
  const LandlordManagement({super.key});

  @override
  State<LandlordManagement> createState() => _LandlordManagementState();
}

class _LandlordManagementState extends State<LandlordManagement> {
  late Future<List<GetHouse>> futureLandlordHouses;
  int? userIdShared;
  List<Locations> locations = [];

  @override
  void initState() {
    super.initState();
    futureLandlordHouses = fetchHouses();
    _loadUserType();
    _fetchLocations();
  }

  Future<void> _loadUserType() async {
    int? id = await UserPreferences.getUserId();
    setState(() {
      userIdShared = id ?? 0;
    });
  }

  Future<void> _fetchLocations() async {
    try {
      List<Locations> fetchedLocations = await fetchLocations();
      setState(() {
        locations = fetchedLocations;
      });
    } catch (e) {
      log('error fetching locations!');
    }
  }

  String getLocationName(int locationId) {
    final location = locations.firstWhere(
      (loc) => loc.locationId == locationId,
      orElse: () => Locations(
        locationId: 0,
        area: "unknown",
      ),
    );
    return '${location.area}, ${location.town}, ${location.county}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Landlord Management'),
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<List<GetHouse>>(
        future: futureLandlordHouses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green,
                    strokeWidth: 6.0,
                  ),
                  SizedBox(height: 10),
                  Text("Loading, please wait...",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              )),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/notFound.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No houses available.'));
          }

          final houses = snapshot.data!;

          final filteredHouses = houses
              .where((house) => house.landlordId == userIdShared)
              .toList();

          return ListView.builder(
            itemCount: filteredHouses.length,
            itemBuilder: (context, index) {
              final house = filteredHouses[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HouseDetailsPage(house: house),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: house.images!.isNotEmpty
                              ? BlurCachedImage(
                                  imageUrl: '$devUrl${house.images![0]}',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/splash.jpeg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        house.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ksh ${house.rentAmount}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            getLocationName(house.locationDetail!),
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: const Color.fromARGB(255, 24, 139, 7),
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_home),
            label: 'Add House',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddHousePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
