import 'dart:async';
import 'package:flutter/material.dart';
import 'package:homi_2/chat%20feature/DB/chat_db_helper.dart';
import 'package:homi_2/models/ads.dart';
import 'package:homi_2/models/chat.dart';
import 'package:homi_2/services/fetch_ads_service.dart';
import 'package:homi_2/services/fetch_chat_messages_service.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:homi_2/views/Shared/ad_details_page.dart';
import 'package:homi_2/views/Shared/chart_card.dart.dart';
import 'package:homi_2/views/Shared/chat_page.dart';
import 'package:video_player/video_player.dart';

///
/// TODO: How do i synagize the offline and onlline chats?
///
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<ChatRoom>> chatRoomsFuture;
  late Future<List<ChatRoom>> chatRoomsFutureFromDB;
  late Future<List<Ad>> futureAds;
  late List<Ad> ads;

  String selectedFilter = 'All';
  final bool isConditionMet = true;
  VideoPlayerController? _videoController;
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  bool _isPaused = false;

  String? authToken;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
    _startAutoScroll();
    _pageController = PageController(initialPage: 0);

    futureAds = fetchAds();
    chatRoomsFuture = fetchChatRooms();
    chatRoomsFutureFromDB = DatabaseHelper().getChatRoomsWithMessages();
  }

  List<ChatRoom> filterChats(List<ChatRoom> chats, String filter) {
    if (filter == 'All') return chats;
    // if (filter == 'unRead') return chats.where((c) => !c.isRead).toList();
    if (filter == 'Groups') return chats.where((c) => c.isGroup).toList();
    return chats;
  }

  Future<void> _loadAuthToken() async {
    authToken = await UserPreferences.getAuthToken();
    currentUserEmail = (await UserPreferences.getUserEmail())!;

    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isPaused && _pageController.hasClients) {
        _currentPage++;

        if (_currentPage >= ads.length) {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onAdTap(int index) {
    setState(() {
      _isPaused = !_isPaused;
      _currentPage = index;
    });
    if (_isPaused) {
      _timer?.cancel();
    } else {
      _startAutoScroll();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO : this page has an overflow at the bottom

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: isConditionMet
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              child: Text("Homichat",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF105A01))),
                            ),
                            SizedBox(
                              height: 48,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                children: [
                                  buildFilterChip(
                                      "All", selectedFilter == 'All', (val) {
                                    setState(() =>
                                        selectedFilter = val ? 'All' : '');
                                  }),
                                  buildFilterChip(
                                      "Groups", selectedFilter == 'Groups',
                                      (val) {
                                    setState(() =>
                                        selectedFilter = val ? 'Groups' : '');
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: FutureBuilder<List<ChatRoom>>(
                                  future: chatRoomsFutureFromDB,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                          child: Text('Failed to load chats.'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.chat_bubble_outline,
                                                size: 60,
                                                color: Color(0xFF026B13)),
                                            SizedBox(height: 10),
                                            Text(
                                              'No Chats Available',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF026B13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    // Filter chats based on selectedFilter if needed
                                    final chatRooms = snapshot.data!;
                                    final filtered =
                                        filterChats(chatRooms, selectedFilter);

                                    return ListView.separated(
                                      key: ValueKey(selectedFilter),
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 2),
                                      itemBuilder: (context, index) {
                                        final chat = filtered[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                  chat: chat,
                                                  token: authToken!,
                                                  userEmail: currentUserEmail!,
                                                ),
                                              ),
                                            );
                                          },
                                          child: ChatCard(chat: chat),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          key: ValueKey('comingSoon'),
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.upcoming,
                                    size: 80, color: Color(0xFF026B13)),
                                SizedBox(height: 20),
                                Text(
                                  'Chat Feature Unavailable',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Coming Soon!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
            const Spacer(),
            FutureBuilder<List<Ad>>(
              future: futureAds,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.green,
                        strokeWidth: 6.0,
                      ),
                      SizedBox(height: 10),
                      Text("Loading, please wait...",
                          style: TextStyle(fontSize: 16)),
                    ],
                  );
                } else if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: double.infinity,
                              height: 250,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF105A01),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "No advertisements available",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  ads = snapshot.data!;
                  return SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: ads.length,
                      itemBuilder: (context, index) {
                        final ad = ads[index];

                        return GestureDetector(
                          onTap: () {
                            _onAdTap(index);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdDetailPage(
                                  ad: ad,
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade300,
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5,
                                        offset: Offset(0, 3)),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9.5,
                                    child: ad.imageUrl != null
                                        ? Image.network(
                                            '$devUrl${ad.imageUrl!}',
                                            fit: BoxFit.cover,
                                          )
                                        : const Center(
                                            child: Text(
                                              'No Image Available',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 15,
                                left: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF046803),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ad.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilterChip(
      String label, bool isSelected, Function(bool) onSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.black,
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF105A01),
        backgroundColor: Colors.grey[200],
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
              color: isSelected ? Colors.green : Colors.grey.shade300),
        ),
        onSelected: onSelected,
      ),
    );
  }
}

    // Lottie.asset('assets/animations/chatFeature.json',
                    //     width: double.infinity, height: 200),
                    // const SizedBox(height: 10),
                    // const Text("Lets manage your living space!",
                    //     style: TextStyle(fontSize: 18)),
