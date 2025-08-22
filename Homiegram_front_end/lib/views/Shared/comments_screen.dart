import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/models/comments.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/models/post_comments.dart';
import 'package:homi_2/services/comments_service.dart';
import 'package:homi_2/services/user_data.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:http/http.dart' as http;

class CommentsScreen extends StatefulWidget {
  final GetHouse house;
  const CommentsScreen({super.key, required this.house});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<GetComments> _comments = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _loadUserId();
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
    await PostComments.postComment(
      houseId: widget.house.houseId.toString(),
      userId: userId.toString(),
      comment: comment,
      nested: true,
      nestedId: '3',
    );

    await _fetchComments();
  }

  void _submitComment(TextEditingController commentController) {
    final String comment = commentController.text.trim();
    if (comment.isEmpty) {
      showCustomSnackBar(context, 'Comment cannot be empty',
          type: SnackBarType.warning);
    } else {
      addComment(comment);
      commentController.clear();
    }
  }

  Future<void> deleteComment(int commentId) async {
    String? token = await UserPreferences.getAuthToken();
    String url = '$devUrl/comments/deleteComments/$commentId/';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    try {
      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == 204) {
        setState(() {
          _comments.removeWhere((comment) => comment.commentId == commentId);
        });
      } else if (response.statusCode == 404) {
        if (!mounted) return;

        showCustomSnackBar(context, 'Comment already deleted',
            type: SnackBarType.warning);
      } else {
        if (!mounted) return;

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
    final userId = await UserPreferences.getUserId();
    String? token = await UserPreferences.getAuthToken();
    if (userId == null) return;
    final url = Uri.parse("$devUrl/comments/post/");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Token $token',
      },
      body: jsonEncode(
          {"comment_id": commentId, "action": action, "user_id": userId}),
    );

    if (response.statusCode == 200) {
      setState(() {});
    } else {
      log("Failed to react: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    int housseId = widget.house.houseId;
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Comments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            CommentList(
              comments: _comments,
              onDelete: deleteComment,
              onReact: onReact,
              houseIdHere: housseId,
            ),
            const SizedBox(height: 10),
            // TODO : have this as a bottom bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Tell us about ${widget.house.name}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF126E06)),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Your comment',
                      labelStyle: TextStyle(color: Color(0xFF126E06)),
                    ),
                    cursorColor: const Color(0xFF126E06),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _submitComment(commentController);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0x95154D07),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Post Comment'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///TODO : refactor the comments style to be more appealing
class CommentList extends StatefulWidget {
  final List<GetComments> comments;
  final Function(int, String) onReact;
  final Function(int) onDelete;
  final int houseIdHere;

  const CommentList({
    required this.comments,
    required this.onReact,
    required this.onDelete,
    required this.houseIdHere,
    Key? key,
  }) : super(key: key);

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  int? userId;
  Map<int, int> likesMap = {};
  Map<int, int> dislikesMap = {};
  int? replyingToCommentId;
  final TextEditingController replyController = TextEditingController();
  Map<int, String> userReactions = {};

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _initializeReactionCounts();
  }

  Future<void> _loadUserId() async {
    int? id = await UserPreferences.getUserId();
    setState(() {
      userId = id ?? 0;
    });
  }

  void _initializeReactionCounts() {
    for (var comment in widget.comments) {
      likesMap[comment.commentId] = comment.likes;
      dislikesMap[comment.commentId] = comment.dislikes;
    }
  }

  void _handleReact(int commentId, String reactionType) {
    setState(() {
      String? currentReaction = userReactions[commentId];

      if (currentReaction == reactionType) {
        userReactions.remove(commentId);
        if (reactionType == "like") {
          likesMap[commentId] = (likesMap[commentId] ?? 1) - 1;
        } else {
          dislikesMap[commentId] = (dislikesMap[commentId] ?? 1) - 1;
        }
        widget.onReact(commentId, "remove");
      } else {
        if (currentReaction == "like") {
          likesMap[commentId] = (likesMap[commentId] ?? 1) - 1;
        } else if (currentReaction == "dislike") {
          dislikesMap[commentId] = (dislikesMap[commentId] ?? 1) - 1;
        }

        userReactions[commentId] = reactionType;
        if (reactionType == "like") {
          likesMap[commentId] = (likesMap[commentId] ?? 0) + 1;
        } else {
          dislikesMap[commentId] = (dislikesMap[commentId] ?? 0) + 1;
        }

        widget.onReact(commentId, reactionType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<int?, List<GetComments>> groupedComments = {};

    for (var comment in widget.comments) {
      groupedComments.putIfAbsent(comment.parent, () => []).add(comment);
    }

    List<GetComments> rootComments = groupedComments[null] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rootComments.length,
          itemBuilder: (context, index) {
            final comment = rootComments.reversed.toList()[index];
            return _buildCommentTile(comment, groupedComments,
                house: widget.houseIdHere);
          },
        ),
      ],
    );
  }

  void _sendReply(int parentCommentId, int houseIdnew) async {
    final replyText = replyController.text.trim();
    if (replyText.isEmpty) return;

    final url = Uri.parse("$devUrl/comments/post/");
    String? token = await UserPreferences.getAuthToken();

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Token $token"
      },
      body: jsonEncode({
        "house_id": houseIdnew,
        "user_id": userId,
        "comment": replyText,
        "parent": parentCommentId,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      replyController.clear();
      setState(() {
        replyingToCommentId = null;
      });
      fetchComments(houseIdnew);
    } else {}
  }

  Widget _buildCommentTile(
    GetComments comment,
    Map<int?, List<GetComments>> groupedComments, {
    int depth = 0,
    int? house,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 20.0, top: 4, bottom: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0x95154D07),
          border: Border.all(color: const Color(0xFF126E06), width: 1.0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(comment.comment,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _handleReact(comment.commentId, "like"),
                      icon: const Icon(Icons.thumb_up,
                          size: 20, color: Colors.white),
                    ),
                    Text(
                      "${likesMap[comment.commentId] ?? comment.likes}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _handleReact(
                        comment.commentId,
                        "dislike",
                      ),
                      icon: const Icon(Icons.thumb_down,
                          size: 20, color: Colors.white),
                    ),
                    Text(
                        "${dislikesMap[comment.commentId] ?? comment.dislikes}",
                        style: const TextStyle(color: Colors.white)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          replyingToCommentId = comment.commentId;
                        });
                      },
                      child: const Text(
                        "Reply",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                if (comment.userId == userId)
                  IconButton(
                    onPressed: () => widget.onDelete(comment.commentId),
                    icon: const Icon(Icons.delete, color: Colors.white),
                  ),
              ],
            ),
            if (replyingToCommentId == comment.commentId)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: replyController,
                      decoration: InputDecoration(
                        hintText: "Write a reply...",
                        filled: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _sendReply(comment.commentId, house!),
                        child: const Text("Send"),
                      ),
                    )
                  ],
                ),
              ),
            if (groupedComments.containsKey(comment.commentId))
              ...groupedComments[comment.commentId]!
                  .map((reply) => _buildCommentTile(reply, groupedComments,
                      depth: depth + 1))
                  .toList(),
          ],
        ),
      ),
    );
  }
}
