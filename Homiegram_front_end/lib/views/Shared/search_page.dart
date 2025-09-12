import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/star_ratings.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/models/amenities.dart';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/services/get_amenities.dart';
import 'package:homi_2/services/get_house_service.dart';
import 'package:homi_2/services/get_locations.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/views/Shared/bookmark_page.dart';
import 'package:homi_2/views/Shared/filter_houses.dart';
import 'package:homi_2/views/Shared/house_details_screen.dart';
import 'package:lottie/lottie.dart';

const devUrl = AppConstants.baseUrl;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<GetHouse> allHouses = [];
  List<GetHouse> displayedHouses = [];
  List<Amenities> amenities = [];
  List<Locations> locations = [];
  bool isLoadingHouses = true;
  bool isLoadingAmenities = true;
  int? userId;
  late Future<List<Locations>> futureLocations;

  // Parameters to enable searching and filtering.
  String searchQuery = "";
  Locations? selectedLocation;
  List<Amenities> selectedAmenities = [];
  int? minRent;
  int? maxRent;

  @override
  void initState() {
    super.initState();
    _loadAllHouses();
    _loadUserId();
    _fetchAmenities();
    _fetchLocations();
  }

  Future<void> _loadUserId() async {
    int? id = await UserPreferences.getUserId();
    setState(() {
      userId = id;
    });
  }

  Future<void> _loadAllHouses() async {
    try {
      List<GetHouse> fetchedHouses = await fetchHouses();
      setState(() {
        allHouses = fetchedHouses;
        displayedHouses = fetchedHouses;
        isLoadingHouses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingHouses = false;
      });
    }
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

  Future<void> _fetchAmenities() async {
    try {
      List<Amenities> fetchedAmenities = await fetchAmenities();

      setState(() {
        amenities = fetchedAmenities;
      });
    } catch (e) {
      log('error fetching amenities!');
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

  void applyFilters() {
    setState(() {
      final safeSearchQuery = searchQuery.toLowerCase();

      displayedHouses = allHouses.where((house) {
        final matchesSearch =
            house.name.toLowerCase().contains(safeSearchQuery);

        final matchesLocation = selectedLocation == null
            ? true
            : house.locationDetail == selectedLocation!.locationId;

        final matchesAmenities = selectedAmenities.isEmpty
            ? true
            : selectedAmenities.every((a) => house.amenities.contains(a.id));

        final rentValue = double.tryParse(house.rentAmount) ?? 0;
        final matchesRent = (minRent == 0 && maxRent == 1000000)
            ? true
            : (rentValue >= minRent! && rentValue <= maxRent!);

        return matchesSearch &&
            matchesLocation &&
            matchesRent &&
            matchesAmenities;
      }).toList();
    });
  }

  void _onApplyFilters(Map<String, dynamic> filters) {
    setState(() {
      selectedLocation =
          filters["location"] is Locations ? filters["location"] : null;
      selectedAmenities = filters["amenities"] != null
          ? List<Amenities>.from(filters["amenities"])
          : [];

      if (filters["rent"] is RangeValues) {
        final range = filters["rent"] as RangeValues;

        if (range.start > 0 || range.end < 500000) {
          minRent = range.start.toInt();
          maxRent = range.end.toInt();
        } else {
          minRent = 0;
          maxRent = 500000;
        }
      } else {
        minRent = 0;
        maxRent = 500000;
      }
    });

    applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TextField(
            decoration: const InputDecoration(
              hintText: 'Search houses...',
              border: InputBorder.none,
            ),
            onChanged: (query) {
              setState(() {
                displayedHouses = allHouses
                    .where((house) =>
                        house.name.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              });
            },
          ),
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.filter_list,
              ),
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(48),
                    ),
                  ),
                  builder: (_) => FilterSheetHouses(
                    locations: locations,
                    amenities: amenities,
                    onApply: _onApplyFilters,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.bookmark_added,
                color: Color(0xFF126E06),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookmarkedHousesPage(
                      userId: userId!,
                    ),
                  ),
                );
              },
            ),
          ]),
      body: isLoadingHouses
          ? const Center(
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
            ))
          : Column(
              children: [
                Expanded(
                  child: displayedHouses.isEmpty
                      ? Center(
                          child: Lottie.asset(
                            'assets/animations/notFound.json',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedHouses.length,
                          itemBuilder: (context, index) {
                            displayedHouses
                                .sort((a, b) => b.rating.compareTo(a.rating));
                            final house = displayedHouses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SpecificHouseDetailsScreen(
                                              house: house),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 180,
                                      width: double.infinity,
                                      child: house.images!.isNotEmpty
                                          ? BlurCachedImage(
                                              imageUrl:
                                                  '$devUrl${house.images?.first}',
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/images/splash.jpeg',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            house.name,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF126E06)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text("Rent: ${house.rentAmount}"),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Text("Rating:"),
                                              RatingStars(
                                                  rating:
                                                      house.rating.toDouble())
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                              "location: ${getLocationName(house.locationDetail!)}"),
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
