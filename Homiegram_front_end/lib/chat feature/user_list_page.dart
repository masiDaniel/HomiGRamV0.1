import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chat_page.dart';

class UserListPage extends StatefulWidget {
  final String jwtToken;
  final int userId;

  const UserListPage({super.key, required this.jwtToken, required this.userId});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List users = [];

  List<Map<String, dynamic>> recentChats = [];
  bool showSearchResults = false;

  Future<void> fetchUsers() async {
    final res = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/accounts/users/"),
      headers: {"Authorization": "Bearer ${widget.jwtToken}"},
    );

    if (res.statusCode == 200) {
      setState(() {
        users = jsonDecode(res.body);
        showSearchResults = true;
      });
    } else {}
  }

  Future<String?> getOrCreateRoom(Map user) async {
    final res = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/chat/get-or-create-room/"),
      headers: {
        "Authorization": "Bearer ${widget.jwtToken}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"receiver_id": user['id']}),
    );

    if (res.statusCode == 200) {
      final roomName = jsonDecode(res.body)["room_name"];

      // Save to recent chats if not already there
      final exists = recentChats.any((chat) => chat["id"] == user["id"]);
      if (!exists) {
        setState(() {
          recentChats.add({
            "username": user["username"],
            "id": user["id"],
            "room_name": roomName,
          });
        });
      }

      return roomName;
    } else {
      return null;
    }
  }

  void openChat(Map user, String roomName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          jwtToken: widget.jwtToken,
          roomName: roomName,
          username: user["username"],
          receiverId: user["id"],
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Home")),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: fetchUsers,
            child: const Text("Search Users"),
          ),
          const SizedBox(height: 16),

          // Show previous chat rooms
          if (recentChats.isNotEmpty)
            Expanded(
              child: Column(
                children: [
                  const Text(
                    "Recent Chats",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: recentChats.length,
                      itemBuilder: (context, index) {
                        final chat = recentChats[index];
                        return ListTile(
                          title: Text(chat["username"]),
                          onTap: () => openChat(chat, chat["room_name"]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Show fetched users only after clicking "Search Users"
          if (showSearchResults)
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  // Don't show self
                  if (user["id"] == widget.userId) return Container();

                  return ListTile(
                    title: Text(user["username"]),
                    onTap: () async {
                      final roomName = await getOrCreateRoom(user);
                      if (roomName != null) openChat(user, roomName);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
