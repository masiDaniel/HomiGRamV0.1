import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/models/comments.dart';
import 'package:homi_2/models/get_house.dart';
import 'package:homi_2/services/comments_service_refined.dart';
import 'package:homi_2/services/post_comments_service.dart';
import 'package:homi_2/services/comments_service.dart';
import 'package:homi_2/services/user_data.dart';

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
    try {
      final statusCode = await CommentService.deleteComment(commentId);

      if (!mounted) return;

      if (statusCode == 204) {
        setState(() {
          _comments.removeWhere((comment) => comment.commentId == commentId);
        });
      } else if (statusCode == 404) {
        showCustomSnackBar(context, 'Comment already deleted',
            type: SnackBarType.warning);
      } else {
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
    final statusCode = await CommentService.reactToComment(
      commentId: commentId,
      action: action,
    );

    if (statusCode == 200) {
      setState(() {}); // refresh UI
    } else {
      log("Failed to react, status: $statusCode");
      showCustomSnackBar(context, "Failed to react");
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    int housseId = widget.house.houseId;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          ],
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFF126E06),
                        width: 2,
                      ),
                    ),
                  ),
                  cursorColor: const Color(0xFF126E06),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _submitComment(commentController);
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(14),
                  backgroundColor: const Color(0xFF126E06),
                  elevation: 2,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rootComments.length,
            itemBuilder: (context, index) {
              final comment = rootComments.reversed.toList()[index];
              return CommentTile(
                comment: comment,
                groupedComments: groupedComments,
                depth: 0,
                houseId: widget.houseIdHere,
                userId: userId,
                replyingToCommentId: replyingToCommentId,
                likesMap: likesMap,
                dislikesMap: dislikesMap,
                onReact: _handleReact,
                onDelete: widget.onDelete,
                onReplyPressed: (id) =>
                    setState(() => replyingToCommentId = id),
                onSendReply: _sendReply,
                replyController: replyController,
              );
            },
          )
        ],
      ),
    );
  }

  void _sendReply(int parentCommentId, int houseId) async {
    final replyText = replyController.text.trim();
    if (replyText.isEmpty) return;

    final statusCode = await CommentService.sendReply(
      parentCommentId: parentCommentId,
      houseId: houseId,
      userId: userId,
      replyText: replyText,
    );

    if (statusCode == 201 || statusCode == 200) {
      replyController.clear();
      setState(() {
        replyingToCommentId = null;
      });
      fetchComments(houseId);
    } else {
      showCustomSnackBar(context, "Failed to send reply");
    }
  }
}

class CommentTile extends StatelessWidget {
  final GetComments comment;
  final Map<int?, List<GetComments>> groupedComments;
  final int depth;
  final int? houseId;
  final int? userId;
  final int? replyingToCommentId;
  final Map<int, int> likesMap;
  final Map<int, int> dislikesMap;

  final Function(int, String) onReact;
  final Function(int) onDelete;
  final Function(int) onReplyPressed;
  final Function(int, int) onSendReply;

  final TextEditingController replyController;

  const CommentTile({
    super.key,
    required this.comment,
    required this.groupedComments,
    required this.depth,
    required this.houseId,
    required this.userId,
    required this.replyingToCommentId,
    required this.likesMap,
    required this.dislikesMap,
    required this.onReact,
    required this.onDelete,
    required this.onReplyPressed,
    required this.onSendReply,
    required this.replyController,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = comment.userId == userId;
    final isReplying = replyingToCommentId == comment.commentId;

    return Padding(
      padding:
          EdgeInsets.only(left: depth * 16.0, top: 6, bottom: 6, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connector line for replies
          if (depth > 0)
            Container(
              width: 2,
              height: 60,
              margin: const EdgeInsets.only(right: 8),
              color: Colors.green.withOpacity(0.4),
            ),

          // Bubble + content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF126E06).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    comment.comment,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Actions row
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.thumb_up_alt_outlined,
                          size: 16, color: Colors.grey),
                      onPressed: () => onReact(comment.commentId, "like"),
                    ),
                    Text(
                      "${likesMap[comment.commentId] ?? comment.likes}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.thumb_down_alt_outlined,
                          size: 16, color: Colors.grey),
                      onPressed: () => onReact(comment.commentId, "dislike"),
                    ),
                    Text(
                      "${dislikesMap[comment.commentId] ?? comment.dislikes}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onReplyPressed(comment.commentId),
                      child: const Text(
                        "Reply",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => onDelete(comment.commentId),
                        child: const Icon(Icons.delete,
                            size: 16, color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),

                // Reply input
                if (isReplying)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ReplyInput(
                      replyController: replyController,
                      onSend: () => onSendReply(comment.commentId, houseId!),
                    ),
                  ),

                // Nested replies
                if (groupedComments.containsKey(comment.commentId))
                  ...groupedComments[comment.commentId]!
                      .map((reply) => CommentTile(
                            comment: reply,
                            groupedComments: groupedComments,
                            depth: depth + 1,
                            houseId: houseId,
                            userId: userId,
                            replyingToCommentId: replyingToCommentId,
                            likesMap: likesMap,
                            dislikesMap: dislikesMap,
                            onReact: onReact,
                            onDelete: onDelete,
                            onReplyPressed: onReplyPressed,
                            onSendReply: onSendReply,
                            replyController: replyController,
                          ))
                      .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentActions extends StatelessWidget {
  final GetComments comment;
  final bool isOwner;
  final Map<int, int> likesMap;
  final Map<int, int> dislikesMap;
  final Function(int, String) onReact;
  final Function(int) onDelete;
  final Function(int) onReplyPressed;

  const CommentActions({
    super.key,
    required this.comment,
    required this.isOwner,
    required this.likesMap,
    required this.dislikesMap,
    required this.onReact,
    required this.onDelete,
    required this.onReplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => onReact(comment.commentId, "like"),
              icon: const Icon(Icons.thumb_up, size: 20, color: Colors.white),
            ),
            Text(
              "${likesMap[comment.commentId] ?? comment.likes}",
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onReact(comment.commentId, "dislike"),
              icon: const Icon(Icons.thumb_down, size: 20, color: Colors.white),
            ),
            Text(
              "${dislikesMap[comment.commentId] ?? comment.dislikes}",
              style: const TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () => onReplyPressed(comment.commentId),
              child: const Text(
                "Reply",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
        if (isOwner)
          IconButton(
            onPressed: () => onDelete(comment.commentId),
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
      ],
    );
  }
}

class ReplyInput extends StatelessWidget {
  final TextEditingController replyController;
  final VoidCallback onSend;

  const ReplyInput({
    super.key,
    required this.replyController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          TextField(
            controller: replyController,
            decoration: InputDecoration(
              hintText: "Write a reply...",
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.green),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onSend,
              child: const Text("Send"),
            ),
          )
        ],
      ),
    );
  }
}
