import 'dart:async';
import 'dart:convert';
import 'package:homi_2/models/chat.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final StreamController<List<ChatRoom>> _chatRoomsController =
      StreamController.broadcast();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat_app.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create tables
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chatrooms (
        id INTEGER PRIMARY KEY,
        name TEXT,
        label TEXT,
        participants TEXT,  -- Stored as JSON array
        last_message TEXT,  -- Stored as JSON object
        is_group INTEGER,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY,
        chatroom_id INTEGER,
        sender TEXT,
        content TEXT,
        timestamp TEXT,
        FOREIGN KEY (chatroom_id) REFERENCES chatrooms (id)
      )
    ''');
  }

  Future<List<ChatRoom>> getChatRoomsWithMessages() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'chatrooms',
      orderBy: 'updated_at DESC',
    );

    List<ChatRoom> chatRooms = [];

    for (var map in maps) {
      // Fetch messages for this room
      final messages = await getMessagesForRoom(map['id']);

      chatRooms.add(
        ChatRoom(
          id: map['id'],
          name: map['name'],
          label: map['label'],
          participants: map['participants'] != null
              ? (json.decode(map['participants']) as List)
                  .map((p) => Participants.fromJson(p))
                  .toList()
              : [],
          lastMessage: map['last_message'] != null
              ? Message.fromJson(json.decode(map['last_message']))
              : null,
          isGroup: map['is_group'] == 1,
          updatedAt: DateTime.parse(map['updated_at']),
          messages: messages,
        ),
      );
    }

    return chatRooms;
  }

  // Insert or update chatroom
  Future<void> insertOrUpdateChatroom(ChatRoom chatroom) async {
    final db = await database;
    await db.insert(
      'chatrooms',
      {
        'id': chatroom.id,
        'name': chatroom.name,
        'label': chatroom.label,
        'participants': json.encode(
          chatroom.participants.map((p) => p.toJson()).toList(),
        ),
        'last_message': chatroom.lastMessage != null
            ? json.encode(chatroom.lastMessage!.toJson())
            : null,
        'is_group': chatroom.isGroup ? 1 : 0,
        'updated_at': chatroom.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _notifyChatRooms();
  }

  // Insert or update message
  Future<void> insertOrUpdateMessage(Message message, int chatroomId) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'id': message.id,
        'chatroom_id': chatroomId,
        'sender': message.sender,
        'content': message.content,
        'timestamp': message.timestamp.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all chatrooms
  Future<List<ChatRoom>> getChatRooms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chatrooms',
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return ChatRoom(
        id: maps[i]['id'],
        name: maps[i]['name'],
        label: maps[i]['label'],
        participants: maps[i]['participants'] != null
            ? (json.decode(maps[i]['participants']) as List)
                .map((p) => Participants.fromJson(p))
                .toList()
            : [],
        lastMessage: maps[i]['last_message'] != null
            ? Message.fromJson(json.decode(maps[i]['last_message']))
            : null,
        isGroup: maps[i]['is_group'] == 1,
        updatedAt: DateTime.parse(maps[i]['updated_at']),
        messages: [], // This will be fetched separately
      );
    });
  }

  // Get messages for a chatroom
  Future<List<Message>> getMessagesForRoom(int chatroomIdPased) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'chatroom_id = ?',
      whereArgs: [chatroomIdPased],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) {
      return Message(
        id: maps[i]['id'],
        sender: maps[i]['sender'],
        content: maps[i]['content'],
        timestamp: DateTime.parse(maps[i]['timestamp']),
        chatroomId: chatroomIdPased,
      );
    });
  }

  // Delete a chatroom
  Future<void> deleteChatRoom(int id) async {
    final db = await database;
    await db.delete('chatrooms', where: 'id = ?', whereArgs: [id]);
    await db.delete('messages', where: 'chatroom_id = ?', whereArgs: [id]);
  }

  // Delete a single message
  Future<void> deleteMessage(int id) async {
    final db = await database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  // Clear all tables
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('chatrooms');
    await db.delete('messages');
  }

  /// Expose stream
  Stream<List<ChatRoom>> watchChatRooms() {
    _notifyChatRooms(); // emit initial data
    return _chatRoomsController.stream;
  }

  Future<void> _notifyChatRooms() async {
    final chats = await getChatRoomsWithMessages();
    _chatRoomsController.add(chats);
  }

  void dispose() {
    _chatRoomsController.close();
  }
}
