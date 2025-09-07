import 'package:flutter/material.dart';
import 'package:homi_2/chat%20feature/DB/chat_db_helper.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/components/secure_tokens.dart';
import 'package:homi_2/models/chat.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

const chatUrl = AppConstants.chatBaseUrl;
const devUrl = AppConstants.baseUrl;

class ChatPage extends StatefulWidget {
  final ChatRoom chat;
  final String token;
  final String userEmail;

  const ChatPage({
    Key? key,
    required this.chat,
    required this.token,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel channel;
  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    final wsUrl = Uri.parse(
        '$chatUrl/ws/chat/${widget.chat.name}/?token=${widget.token}');

    channel = WebSocketChannel.connect(wsUrl);

    // Listen for incoming messages
    channel.stream.listen((data) {
      final decoded = jsonDecode(data);

      final newMessage = Message(
        id: decoded['id'],
        sender: decoded['sender'],
        content: decoded['message'],
        timestamp: DateTime.parse(decoded['timestamp']),
        chatroomId: widget.chat.id,
      );

      setState(() {
        messages.add(newMessage);
      });

      DatabaseHelper().insertOrUpdateMessage(newMessage, widget.chat.id);
    });
    messages = widget.chat.messages;

    fetchNewMessages();
  }

  Future<void> fetchInitialMessages() async {
    String? token = await getAccessToken();
    final url = "$devUrl/chat/messages/${widget.chat.name}";
    final response = await http.get(Uri.parse(url), headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final fetchedMessages = data.map((m) => Message.fromJson(m)).toList();

      for (var msg in fetchedMessages) {
        await DatabaseHelper().insertOrUpdateMessage(msg, widget.chat.id);
      }

      setState(() {
        messages = fetchedMessages;
      });
    }
  }

  Future<void> fetchNewMessages() async {
    String? token = await getAccessToken();
    if (messages.isEmpty) {
      return fetchInitialMessages();
    }

    int lastId = messages.last.id!;
    final url = "$devUrl/chat/messages/${widget.chat.name}?after_id=$lastId";

    final response = await http.get(Uri.parse(url), headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final newMessages = data.map((m) => Message.fromJson(m)).toList();

        for (var msg in newMessages) {
          await DatabaseHelper().insertOrUpdateMessage(msg, widget.chat.id);
        }

        setState(() {
          messages.addAll(newMessages);
        });
      }
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final message = {"message": _controller.text.trim()};
    channel.sink.add(jsonEncode(message));
    _controller.clear();
  }

  DateTime formatTimestampToLocalDeviceTime(DateTime utcTime) {
    return utcTime.toLocal();
  }

// Define participant colors (you can expand this palette)
  final participantColors = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.red,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
  ];

// Helper: map emails to colors
  Color getParticipantColor(String email) {
    final index = widget.chat.participants.indexWhere((p) => p.email == email);
    if (index == -1) return Colors.grey; // fallback
    return participantColors[index % participantColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColorMe =
        isDark ? const Color(0xFF4F9E4F) : const Color(0xFFDCF8C6);
    final bubbleColorOther =
        isDark ? const Color(0xFF33373D) : const Color(0xFFF0F0F0);
    final bgColor = isDark
        ? const Color(0xFF121212)
        : const Color.fromARGB(255, 255, 255, 255);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: isDark ? Colors.grey[900] : const Color(0xFF105A01),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.chat.name[0].toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[900] : const Color(0xFF105A01),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.chat.isGroup
                    ? widget.chat.name
                    : (widget.chat.label ?? "Private Chat"),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMe = msg.sender == widget.userEmail;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? bubbleColorMe : bubbleColorOther,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe
                            ? const Radius.circular(16)
                            : const Radius.circular(4),
                        bottomRight: isMe
                            ? const Radius.circular(4)
                            : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (widget.chat.isGroup && !isMe) ...[
                          Text(
                            msg.sender, // assuming msg.sender == email
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: getParticipantColor(msg.sender),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          msg.content,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.grey[200] : Colors.grey[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TimeOfDay.fromDateTime(
                                  formatTimestampToLocalDeviceTime(
                                      msg.timestamp))
                              .format(context),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(30),
                color: isDark ? Colors.black : Colors.white,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color:
                                  isDark ? Colors.grey[500] : Colors.grey[700],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: isDark
                            ? const Color.fromARGB(255, 80, 151, 26)
                            : const Color(0xFF105A01),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
