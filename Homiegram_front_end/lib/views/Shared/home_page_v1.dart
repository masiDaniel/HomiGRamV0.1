import 'dart:async';
import 'package:flutter/material.dart';
import 'package:homi_2/chat%20feature/DB/chat_db_helper.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/ads.dart';
import 'package:homi_2/models/chat.dart';
import 'package:homi_2/models/get_users.dart';
import 'package:homi_2/services/create_chat_room.dart';
import 'package:homi_2/services/fetch_ads_service.dart';
import 'package:homi_2/services/fetch_chat_messages_service.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_service.dart';
import 'package:homi_2/views/Shared/ad_details_page.dart';
import 'package:homi_2/views/Shared/chart_card.dart.dart';
import 'package:homi_2/views/Shared/chat_page.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:video_player/video_player.dart';

const devUrl = AppConstants.baseUrl;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<List<ChatRoom>> chatRoomsStream;
  late Future<List<Ad>> futureAds;
  List<Ad> _ads = [];
  List<GerUsers> users = [];

  String selectedFilter = 'All';
  final bool isConditionMet = true;
  VideoPlayerController? _videoController;
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  final bool _isPaused = false;
  bool isLoading = false;
  String? token;

  String? currentUserEmail;
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();

    _loadUserEmail();
    futureAds = fetchAds();
    fetchUsers();

    chatRoomsStream = dbHelper.watchChatRooms();
    syncChatRooms();

    _startAutoScroll();
    _pageController = PageController(initialPage: 0);
  }

  Future<void> syncChatRooms() async {
    final remoteChats = await fetchChatRooms();
    for (var chat in remoteChats) {
      await DatabaseHelper().insertOrUpdateChatroom(chat);
    }
  }

  List<ChatRoom> filterChats(List<ChatRoom> chats, String filter) {
    if (filter == 'All') return chats;
    // if (filter == 'unRead') return chats.where((c) => !c.isRead).toList();
    if (filter == 'Groups') return chats.where((c) => c.isGroup).toList();
    return chats;
  }

  Future<void> _loadUserEmail() async {
    currentUserEmail = (await UserPreferences.getUserEmail())!;
    token = await getAccessToken();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedUsers = await UserService.fetchUsers();
      if (!mounted) return;
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      if (!mounted) return;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

        if (_currentPage >= _ads.length) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Homigram",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF105A01),
            letterSpacing: 1.2,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: FutureBuilder<List<Ad>>(
                future: futureAds,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                        strokeWidth: 6.0,
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'assets/animations/notFound.json',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "No advertisements!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "To advertise on this space, contact homigram support",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    _ads = snapshot.data!;
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: _ads.length,
                      itemBuilder: (context, index) {
                        final ad = _ads[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdDetailPage(ad: ad),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Stack(
                                children: [
                                  ad.imageUrl != null
                                      ? Image.network(
                                          '$devUrl${ad.imageUrl!}',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Container(
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child: Text(
                                              'No Image Available',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withValues(alpha: 0.6),
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      child: Text(
                                        ad.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          height: 1.3,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: isConditionMet ? _buildChatHeader() : _buildComingSoon(),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: StreamBuilder<List<ChatRoom>>(
                  stream: chatRoomsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildChatShimmer();
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load chats.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    final chatRooms =
                        filterChats(snapshot.data!, selectedFilter);

                    return ListView.separated(
                      key: ValueKey(selectedFilter),
                      itemCount: chatRooms.length,
                      separatorBuilder: (_, __) =>
                          const Divider(endIndent: 30, indent: 90),
                      itemBuilder: (context, index) {
                        final chat = chatRooms[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  chat: chat,
                                  token: token!,
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
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Column(
      key: const ValueKey('chatHeader'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Homichat",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF105A01),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await showUserDialog(context, users);
                },
                icon: const Icon(Icons.add_circle, color: Color(0xFF105A01)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              buildFilterChip("All", selectedFilter == "All",
                  (val) => setState(() => selectedFilter = val ? "All" : "")),
              buildFilterChip(
                  "Groups",
                  selectedFilter == "Groups",
                  (val) =>
                      setState(() => selectedFilter = val ? "Groups" : "")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoon() {
    return const Center(
      key: ValueKey('comingSoon'),
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upcoming, size: 80, color: Color(0xFF026B13)),
            SizedBox(height: 20),
            Text(
              'Chat Feature Unavailable',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Coming Soon!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Color(0xFF026B13)),
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

  Widget _buildChatShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer(
          color: Colors.grey.shade300,
          child: ListTile(
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
            ),
            title: Container(
              height: 14,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
            subtitle: Container(
              height: 12,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        );
      },
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

  Future<GerUsers?> showUserDialog(
      BuildContext context, List<GerUsers> users) async {
    TextEditingController searchController = TextEditingController();
    List<GerUsers> filteredUsers = [];
    bool hasTyped = false;

    return await showDialog<GerUsers>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Start Conversation with:",
                style: TextStyle(color: Color(0xFF105A01)),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: "Search User",
                        labelStyle: const TextStyle(
                          color: Color(0xFF105A01),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF105A01),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF105A01),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF105A01),
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      cursorColor: const Color(0xFF105A01),
                      onChanged: (query) {
                        setState(() {
                          hasTyped = query.isNotEmpty;
                          filteredUsers = query.isNotEmpty
                              ? users
                                  .where((user) =>
                                      user.firstName!
                                          .toLowerCase()
                                          .contains(query.toLowerCase()) ||
                                      user.email!
                                          .toLowerCase()
                                          .contains(query.toLowerCase()))
                                  .toList()
                              : [];
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    hasTyped
                        ? Expanded(
                            child: filteredUsers.isNotEmpty
                                ? ListView.builder(
                                    itemCount: filteredUsers.length,
                                    itemBuilder: (context, index) {
                                      final user = filteredUsers[index];
                                      return ListTile(
                                        title: Text(
                                            "${user.firstName} (${user.email})"),
                                        onTap: () async {
                                          final chatRoom =
                                              await getOrCreatePrivateChatRoom(
                                                  user.userId!);
                                          Navigator.pop(context);

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                chat: chatRoom,
                                                token: token!,
                                                userEmail: currentUserEmail!,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Text("No matching users found."),
                                  ),
                          )
                        : const Center(
                            child: Text(
                              "Start typing to search for User.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

    // Lottie.asset('assets/animations/chatFeature.json',
                    //     width: double.infinity, height: 200),
                    // const SizedBox(height: 10),
                    // const Text("Lets manage your living space!",
                    //     style: TextStyle(fontSize: 18)),
