import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/models/bookmark.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/services/fetch_bookmarks.dart';
import 'package:homi_2/services/get_house_service.dart';
import 'package:homi_2/views/Shared/house_details_screen.dart';
import 'package:lottie/lottie.dart';

const devUrl = AppConstants.baseUrl;

class BookmarkedHousesPage extends StatefulWidget {
  final int userId;

  const BookmarkedHousesPage({super.key, required this.userId});

  @override
  BookmarkedHousesPageState createState() => BookmarkedHousesPageState();
}

class BookmarkedHousesPageState extends State<BookmarkedHousesPage> {
  late Future<List<GetHouse>> _bookmarkedHousesFuture;

  @override
  void initState() {
    super.initState();
    _bookmarkedHousesFuture = fetchBookmarkedHouses();
  }

  Future<List<GetHouse>> fetchBookmarkedHouses() async {
    final bookmarks = await fetchBookmarks();
    List<GetHouse> allHouses = await fetchHouses();

    final houseIdsForCurrentUser = bookmarks
        .where((bookmark) => bookmark.user == widget.userId)
        .map((bookmark) => bookmark.house)
        .toList();

    List<GetHouse> filteredHouses = allHouses.where((house) {
      return houseIdsForCurrentUser.contains(house.houseId);
    }).toList();

    return filteredHouses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarked Houses')),
      body: FutureBuilder<List<GetHouse>>(
        future: _bookmarkedHousesFuture,
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
              child: Container(
                padding: const EdgeInsets.all(40),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF005E0C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/animations/notFound.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No Houses Found!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We have encountered a problem",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final houses = snapshot.data!;

            if (houses.isEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005E0C).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/animations/notFound.json',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No Bookmarks Found!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We have encountered a problem",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: houses.length,
              itemBuilder: (context, index) {
                final house = houses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SpecificHouseDetailsScreen(house: house),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (house.images?.isNotEmpty ?? false)
                          Image.network(
                            '$devUrl${house.images?.first}',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/images/splash.jpeg',
                            ),
                          ),
                        if (house.images?.isEmpty ?? true)
                          Image.asset(
                            'assets/images/splash.jpeg',
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            house.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("Rent: ${house.rentAmount}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              const Text("Rating:"),
                              buildSimpleStars(house.rating.toDouble()),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  fixedSize: const Size(140, 40),
                                  backgroundColor: const Color(0xFF126E06),
                                ),
                                onPressed: () {
                                  _handleRemoveBookmark(context, house.houseId);
                                },
                                child: const Text(
                                  "Bookmarked",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No bookmarked houses.'));
          }
        },
      ),
    );
  }

  Future<void> _handleRemoveBookmark(BuildContext context, int houseId) async {
    try {
      await PostBookmark.removeBookmark(houseId: houseId);
      log("Bookmark removed successfully.");

      if (!mounted) return;
      setState(() {
        _bookmarkedHousesFuture = fetchBookmarkedHouses();
      });
      if (!mounted) return;
      _showBookmarkRemovedDialog(context);
    } catch (error, stackTrace) {
      log("Error occurred while removing bookmark: $error");
      log(stackTrace.toString());
    }
  }

  void _showBookmarkRemovedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bookmark Removed'),
          content: const Text(
            'This house has been removed from your bookmarks.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF186E1B),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildSimpleStars(double rating) {
    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: Color(0xFF126E06),
      ),
      itemCount: 5,
      itemSize: 20.0,
      direction: Axis.horizontal,
    );
  }
}
