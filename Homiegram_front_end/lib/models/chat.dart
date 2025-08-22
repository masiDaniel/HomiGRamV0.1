import 'dart:convert';

class Message {
  final int? id;
  final int chatroomId;
  final String sender;
  final String content;
  final DateTime timestamp;

  Message({
    this.id,
    required this.chatroomId,
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatroomId: json['chatroom'],
      sender: json['sender'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatroom': chatroomId,
      'sender': sender,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ChatRoom {
  final int id;
  final String name;
  final String? label;
  final List<int> participants;
  late final List<Message> messages;
  final Message? lastMessage;
  final bool isGroup;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    required this.name,
    this.label,
    required this.participants,
    required this.messages,
    this.lastMessage,
    required this.isGroup,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      label: json['label'],
      participants: List<int>.from(json['participants']),
      messages: json['messages'] != null
          ? (json['messages'] as List<dynamic>)
              .map((m) => Message.fromJson(m))
              .toList()
          : [],
      isGroup: json['is_group'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'participants': participants,
      'messages': messages.map((m) => m.toJson()).toList(),
      'is_group': isGroup,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert ChatRoom to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'label': label,
      // Store participants as JSON string
      'participants': json.encode(participants),
      // Store messages as JSON string
      'messages': json.encode(messages.map((m) => m.toJson()).toList()),
      'is_group': isGroup ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create ChatRoom from SQLite Map
  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'],
      name: map['name'],
      label: map['label'],
      participants: map['participants'] != null
          ? List<int>.from(json.decode(map['participants']))
          : [],
      messages: map['messages'] != null
          ? (json.decode(map['messages']) as List<dynamic>)
              .map((m) => Message.fromJson(m))
              .toList()
          : [],
      isGroup: map['is_group'] == 1,
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
