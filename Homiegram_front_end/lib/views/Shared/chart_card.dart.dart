import 'package:flutter/material.dart';
import 'package:homi_2/models/chat.dart';

class ChatCard extends StatefulWidget {
  final ChatRoom chat;

  const ChatCard({required this.chat, Key? key}) : super(key: key);

  @override
  ChatCardState createState() => ChatCardState();
}

class ChatCardState extends State<ChatCard> {
  bool isRead = false;

  @override
  Widget build(BuildContext context) {
    // TODO :  Beutify this page
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/ad3.jpeg'),
          radius: 24,
        ),
        title: Text(
          widget.chat.isGroup
              ? widget.chat.name
              : (widget.chat.label ?? "Group"),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          "chats",
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),

        // trailing: isRead || widget.chat.unreadMessage == 0
        //     ? const Icon(Icons.check_circle, color: Colors.grey)
        //     : const Icon(Icons.circle, color: Colors.green),
      ),
    );
  }
}
