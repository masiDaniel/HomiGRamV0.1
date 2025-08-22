// import 'package:flutter/material.dart';
// import 'package:homi_2/models/chat.dart';

// class ChatCard extends StatefulWidget {
//   final ChatRoom chat;

//   const ChatCard({required this.chat, Key? key}) : super(key: key);

//   @override
//   ChatCardState createState() => ChatCardState();
// }

// class ChatCardState extends State<ChatCard> {
//   bool isRead = false;

//   @override
//   Widget build(BuildContext context) {
//     // TODO :  Beutify this page
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         leading: const CircleAvatar(
//           backgroundImage: AssetImage('assets/images/ad3.jpeg'),
//           radius: 24,
//         ),
//         title: Text(
//           widget.chat.isGroup
//               ? widget.chat.name
//               : (widget.chat.label ?? "Group"),
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         subtitle: const Text(
//           "chats",
//           style: TextStyle(fontSize: 13, color: Colors.grey),
//         ),

//         // trailing: isRead || widget.chat.unreadMessage == 0
//         //     ? const Icon(Icons.check_circle, color: Colors.grey)
//         //     : const Icon(Icons.circle, color: Colors.green),
//       ),
//     );
//   }
// }

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar → fallback with first letter
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFE8F5E9),
            child: Text(
              (widget.chat.label != null
                      ? widget.chat.label![0]
                      : widget.chat.name[0])
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF126E06),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Chat info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chat name
                Text(
                  widget.chat.isGroup
                      ? widget.chat.name
                      : (widget.chat.label ?? widget.chat.name),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                // Subtitle → show last message or "No messages"
                Text(
                  widget.chat.lastMessage?.content ?? "No messages yet",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Right side → time (optional, from updatedAt)
          Text(
            _formatTime(widget.chat.updatedAt),
            style: TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      const weekdays = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
      ];
      return weekdays[dateTime.weekday - 1];
    } else {
      return "${dateTime.day.toString().padLeft(2, '0')}/"
          "${dateTime.month.toString().padLeft(2, '0')}/"
          "${dateTime.year}";
    }
  }
}
