import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/models/amenities.dart';
import 'package:homi_2/models/bookmark.dart';
import 'package:homi_2/models/comments.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/services/comments_service_refined.dart';
import 'package:homi_2/services/post_comments_service.dart';
import 'package:homi_2/services/comments_service.dart';
import 'package:homi_2/services/fetch_bookmarks.dart';
import 'package:homi_2/services/get_amenities.dart';
import 'package:homi_2/services/get_house_service.dart';
import 'package:homi_2/services/get_locations.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/views/Shared/comments_screen.dart';
import 'package:homi_2/views/Shared/rooms_by_type.dart';

const devUrl = AppConstants.baseUrl;

class SpecificHouseDetailsScreen extends StatefulWidget {
  final GetHouse house;

  const SpecificHouseDetailsScreen({super.key, required this.house});

  @override
  State<SpecificHouseDetailsScreen> createState() => _HouseDetailsScreenState();
}

class _HouseDetailsScreenState extends State<SpecificHouseDetailsScreen> {
  late Future<List<GetHouse>> bookmarkedHousesFuture;
  late Future<List<Locations>> futureLocations;

  List<Locations> locations = [];
  List<Amenities> amenities = [];
  List<GetComments> _comments = [];
  bool isBookmarked = false;
  int? userId;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  late List<String> roomCategories;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _loadUserId();
    _fetchLocationsAndAmenities();
    if (widget.house.rooms != null && widget.house.rooms!.isNotEmpty) {
      roomCategories = widget.house.rooms!.keys.toList();
      roomCategories.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    } else {
      roomCategories = [];
    }
    bookmarkedHousesFuture = fetchBookmarkedHouses();

    // TODO : have this as a function and call it here
    bookmarkedHousesFuture.then((bookmarkedHouses) {
      setState(() {
        isBookmarked = bookmarkedHouses
            .any((house) => house.houseId == widget.house.houseId);
      });
    }).catchError((error) {
      debugPrint("Error fetching bookmarked houses: $error");
    });
  }

  Future<void> _loadUserId() async {
    int? id = await UserPreferences.getUserId();
    setState(() {
      userId = id ?? 0;
    });
  }

  Future<void> _fetchComments() async {
    List<GetComments> comments = await fetchComments(widget.house.houseId);
    setState(() {
      _comments = comments;
    });
  }

  void addComment(String comment) async {
    await PostComments.postComment(
      houseId: widget.house.houseId.toString(),
      userId: userId.toString(),
      comment: comment,
      nested: true,
      nestedId: '3',
    );

    await _fetchComments();
  }

  /// how should i refactor this?
  /// have it in a seperate file?
  Future<void> deleteComment(int commentId) async {
    try {
      final statusCode = await CommentService.deleteComment(commentId);

      if (!mounted) return;

      if (statusCode == 204) {
        setState(() {
          _comments.removeWhere((comment) => comment.commentId == commentId);
        });
      } else if (statusCode == 404) {
        showCustomSnackBar(context, 'Comment already deleted',
            type: SnackBarType.warning);
      } else {
        showCustomSnackBar(context, 'We have problems',
            type: SnackBarType.warning);
      }
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Error deleting comment',
          type: SnackBarType.error);
    }
  }

  Map<int, bool> bookmarkedHouses = {};

  Future<List<GetHouse>> fetchBookmarkedHouses() async {
    int? id = await UserPreferences.getUserId();

    final bookmarks = await fetchBookmarks();
    List<GetHouse> allHouses = await fetchHouses();

    final houseIdsForCurrentUser = bookmarks
        .where((bookmark) => bookmark.user == id)
        .map((bookmark) => bookmark.house)
        .toList();

    List<GetHouse> filteredHouses = allHouses.where((house) {
      return houseIdsForCurrentUser.contains(house.houseId);
    }).toList();

    return filteredHouses;
  }

  Future<void> onReact(int commentId, String action) async {
    final statusCode = await CommentService.reactToComment(
      commentId: commentId,
      action: action,
    );
    if (statusCode == 200) {
      setState(() {});
    } else {
      log("Failed to react, status: $statusCode");
      showCustomSnackBar(context, "Failed to react");
    }
  }

  Future<void> _fetchLocationsAndAmenities() async {
    try {
      List<Locations> fetchedLocations = await fetchLocations();
      List<Amenities> fetchedAmenities = await fetchAmenities();
      List<Amenities> availableAmenities = fetchedAmenities
          .where((amenity) => widget.house.amenities.contains(amenity.id))
          .toList();

      setState(() {
        locations = fetchedLocations;
        amenities = availableAmenities;
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF062E00), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.house.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Homigram verified",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // Share house link or details
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
                height: 500,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.house.images!.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final imageUrl = widget.house.images![index];
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
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.house.images!.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F02F502),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'House Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF126E06),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.description, color: Color(0xFF126E06)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Description: ${widget.house.description}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Color(0xFF126E06)),
                      const SizedBox(width: 8),
                      Text('Rent: KES ${widget.house.rentAmount}',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('Rating:', style: TextStyle(fontSize: 16)),
                      buildSimpleStars(widget.house.rating.toDouble())
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF126E06)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            'Location ${getLocationName(widget.house.locationDetail!)}',
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => MapPage(
                        //       destLat: widget.house.latitude!,
                        //       destLng: widget.house.longitude!,
                        //     ),
                        //   ),
                        // );
                      },
                      label: const Text(
                        "Check Map Location",
                        style: TextStyle(
                          color: Color(0xFF126E06),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF126E06), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Browse by Room Type",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: roomCategories.map((category) {
                final String bedroomCount = (category);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomsByTypePage(
                          houseId: widget.house.houseId,
                          bedroomCount: bedroomCount,
                          rooms: widget.house.rooms?[bedroomCount] ?? [],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0x95154D07),
                    ),
                    child: Text(
                      "$bedroomCount Bedroom${bedroomCount != 1 ? 's' : ''}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Amenities",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: amenities.map((amenity) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0x95154D07),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        amenity.name![0].toUpperCase() +
                            amenity.name!.substring(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],
        ),
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
                    onPressed: () {
                      // TODO: have this in a different file/function
                      int houseId = widget.house.houseId;

                      if (isBookmarked) {
                        PostBookmark.removeBookmark(houseId: houseId).then((_) {
                          setState(() {
                            isBookmarked = false;
                          });

                          if (!mounted) return;

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Bookmark Removed'),
                                content: const Text(
                                    'This house has been removed from your bookmarks.'),
                                actions: [
                                  TextButton(
                                    style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Color(0x95154D07)),
                                    ),
                                    onPressed: Navigator.of(context).pop,
                                    child: const Text('OK',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        }).catchError((error) {
                          log("Error occurred while removing bookmark: $error");
                        });
                      } else {
                        PostBookmark.postBookmark(houseId: houseId).then((_) {
                          setState(() {
                            isBookmarked = true;
                          });

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Bookmarked'),
                                content: Text(
                                    '${widget.house.name} has been added to your bookmarks.'),
                                actions: [
                                  TextButton(
                                    style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Color(0x95154D07)),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        }).catchError((error) {
                          log("Error occurred while bookmarking: $error");
                        });
                      }
                    },
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    label: Container(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x95154D07),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CommentsScreen(house: widget.house),
                        ),
                      );
                    },
                    icon: const Icon(Icons.comment, color: Colors.white),
                    label: const Text("Comments",
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

  // TODO : this is duplicated, how do i have it defined once and used across
  // multiple files?

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
