import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:homi_2/components/blured_image.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/components/star_ratings.dart';
import 'package:homi_2/map/map_page.dart';
import 'package:homi_2/models/amenities.dart';
import 'package:homi_2/models/comments.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/models/locations.dart';
import 'package:homi_2/services/comments_service_refined.dart';
import 'package:homi_2/services/house_service.dart';
import 'package:homi_2/services/post_comments_service.dart';
import 'package:homi_2/services/comments_service.dart';
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
    _initRoomCategories();
    _loadBookmarkedState();
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
    await CommentsService.postComment(
      houseId: widget.house.houseId.toString(),
      userId: userId.toString(),
      comment: comment,
      nested: true,
      nestedId: '3',
    );

    await _fetchComments();
  }

  void _initRoomCategories() {
    roomCategories = HouseService.getRoomCategories(widget.house);
  }

  Future<void> _loadBookmarkedState() async {
    final userId = await UserPreferences.getUserId();
    final bookmarkedHouses = await HouseService.fetchBookmarkedHouses(userId);

    if (!mounted) return;

    setState(() {
      isBookmarked = bookmarkedHouses
          .any((house) => house.houseId == widget.house.houseId);
    });
  }

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

  Future<void> onReact(int commentId, String action) async {
    final statusCode = await CommentService.reactToComment(
      commentId: commentId,
      action: action,
    );
    if (!mounted) return;
    if (statusCode == 200) {
      setState(() {});
    } else {
      log("Failed to react, status: $statusCode");
      showCustomSnackBar(context, "Failed to react");
    }
  }

  Future<void> _fetchLocationsAndAmenities() async {
    try {
      final fetchedLocations =
          await HouseService.fetchHouseLocations(widget.house.houseId);
      final fetchedAmenities =
          await HouseService.fetchHouseAmenities(widget.house);

      setState(() {
        locations = fetchedLocations;
        amenities = fetchedAmenities;
      });
    } catch (e) {
      log('error fetching locations!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.house.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            icon: const Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.share,
              ),
              onPressed: () {
                // Share house link or details
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                height: 5,
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
              Container(
                padding: const EdgeInsets.all(12),
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
                        RatingStars(rating: widget.house.rating.toDouble())
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF126E06)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              'Location ${HouseService.getLocationName(locationId: widget.house.locationDetail!, locations: locations)}',
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPage(
                              destLat: widget.house.latitude!,
                              destLng: widget.house.longitude!,
                              houseName: widget.house.name,
                            ),
                          ),
                        );
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
                  ],
                ),
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
                        "$bedroomCount Bedroom",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BottomAppBar(
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final newBookmarkState = await HouseService.toggleBookmark(
                      houseId: widget.house.houseId,
                      currentlyBookmarked: isBookmarked,
                      context: context,
                      houseName: widget.house.name,
                    );
                    if (!mounted) return;
                    setState(() {
                      isBookmarked = newBookmarkState;
                    });
                  } catch (e) {
                    log("Error: $e");
                  }
                },
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                label: const Text("Bookmark",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0x95154D07),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CommentsScreen(house: widget.house),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x95154D07),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 4,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text("Comments"),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              // ElevatedButton.icon(
              //   onPressed: () {
              //     fetchRooms().then((_) {
              //       setState(() {});

              //       showDialog(
              //         context: context,
              //         builder: (BuildContext context) {
              //           return AlertDialog(
              //             title: const Text('Bookmarked'),
              //             content: Text(
              //                 '${widget.house.name} has been added to your bookmarks.'),
              //             actions: [
              //               TextButton(
              //                 style: const ButtonStyle(
              //                   backgroundColor:
              //                       WidgetStatePropertyAll(Color(0x95154D07)),
              //                 ),
              //                 onPressed: () => Navigator.of(context).pop(),
              //                 child: const Text('OK',
              //                     style: TextStyle(color: Colors.white)),
              //               ),
              //             ],
              //           );
              //         },
              //       );
              //     });
              //   },
              //   icon: Icon(
              //     isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              //     color: Colors.white,
              //   ),
              //   label:
              //       const Text("rooms", style: TextStyle(color: Colors.white)),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0x95154D07),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
  // Widget buildSimpleStars(double rating) {
  //   return RatingBarIndicator(
  //     rating: rating,
  //     itemBuilder: (context, index) => const Icon(
  //       Icons.star,
  //       color: Color(0xFF126E06),
  //     ),
  //     itemCount: 5,
  //     itemSize: 20.0,
  //     direction: Axis.horizontal,
  //   );
  // }
}
