import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final String jwtToken;
  final String roomName;
  final String username;
  final int receiverId;
  final int userId;

  const ChatPage({
    Key? key,
    required this.jwtToken,
    required this.roomName,
    required this.username,
    required this.receiverId,
    required this.userId,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel channel;
  List<dynamic> messages = [];
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectWebSocket();
    loadMessages();
  }

  void connectWebSocket() {
    final uri = Uri.parse(
      'ws://192.168.100.18:8000/ws/chat/${widget.roomName}/?token=${widget.jwtToken}',
    );
    channel = WebSocketChannel.connect(uri);

    channel.stream.listen((event) {
      final data = jsonDecode(event);
      if (mounted) {
        setState(() {
          messages.add({'sender': data['sender'], 'content': data['message']});
        });
      }
    });
  }

  Future<void> loadMessages() async {
    final url = Uri.parse(
      '$devUrl/api/chat/messages/${widget.roomName}/',
    );

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${widget.jwtToken}'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));

      setState(() {
        messages = data.reversed.toList();
      });
    } else {}
  }

  void sendMessage() {
    final msg = messageController.text.trim();
    if (msg.isEmpty) return;

    final payload = {'receiver_id': widget.receiverId, 'message': msg};

    channel.sink.add(jsonEncode(payload));
    messageController.clear();
  }

  @override
  void dispose() {
    channel.sink.close();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Room: ${widget.roomName}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender'] == widget.userId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.white : Colors.green[400],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isMe ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendMessage,
                  child: const Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
