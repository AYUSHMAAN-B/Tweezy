import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimal_tweets_app/models/comment.dart';
import 'package:minimal_tweets_app/services/auth/auth_service.dart';
import 'package:minimal_tweets_app/services/post/post_service.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;

  const CommentCard({
    super.key,
    required this.comment,
  });

  @override
  State<CommentCard> createState() => _PostCardState();
}

class _PostCardState extends State<CommentCard> {
  final commentController = TextEditingController();
  late bool liked;
  late int likeCount;

  late DatabaseProvider listeningProvider;
  late DatabaseProvider databaseProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    listeningProvider = Provider.of<DatabaseProvider>(context);
    databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    loadCommentDetails();
  }

  void loadCommentDetails() {
    // Get whether liked or not
    liked = widget.comment.likedBy.contains(widget.comment.userId);

    // Like count
    likeCount = widget.comment.likedBy.length;
  }

  void toggleLike() async {
    await databaseProvider.toggleLikeComment(
      widget.comment.postId,
      widget.comment.id,
    );
  }

  void editComment() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 150,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: TextField(
              controller: commentController,
              maxLength: 100,
              maxLines: 5,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          actions: [
            // Cancel
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
                commentController.clear();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // Post
            MaterialButton(
              onPressed: () async {
                Navigator.of(context).pop();
                databaseProvider.editComment(
                  widget.comment.postId,
                  widget.comment.id,
                  commentController.text,
                );
                commentController.clear();
              },
              child: Text(
                'Post',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showBottomSheetLayout() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.report),
                  title: Text('Report User'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await databaseProvider.reportUser(
                      widget.comment.userId,
                      widget.comment.postId,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Block User'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await databaseProvider.blockUser(widget.comment.userId);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel),
                  title: Text('Cancel'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 16.0, right: 0.0, top: 4.0, bottom: 4.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Details
          SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User Info
                Row(
                  children: [
                    // User Photo
                    widget.comment.userPhoto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            child: Image.network(
                              widget.comment.userPhoto!,
                              scale: 4.0,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),

                    const SizedBox(width: 10),

                    // UserName
                    Text(
                      widget.comment.userName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // @
                    Text(
                      '@${widget.comment.userEmail.split('@')[0]}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Edit / Delete
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () {
                        if (widget.comment.userId ==
                            AuthService().getCurrentUser()!.uid) {
                          showPopover(
                            context: context,
                            bodyBuilder: (context) {
                              return Container(
                                height: 100,
                                width: 100,
                                color: Theme.of(context).colorScheme.tertiary,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        commentController.text =
                                            widget.comment.comment;
                                        Navigator.of(context).pop();
                                        editComment();
                                      },
                                      child: Text('Edit'),
                                    ),
                                    Divider(
                                      height: 2,
                                      indent: 25,
                                      endIndent: 25,
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        await databaseProvider.deleteComment(
                                          widget.comment.postId,
                                          widget.comment.id,
                                        );
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          showBottomSheetLayout();
                        }
                      },
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  },
                )
              ],
            ),
          ),

          Divider(color: Theme.of(context).colorScheme.surface),

          const SizedBox(height: 5),

          // Post
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 40),
            child: Text(
              widget.comment.comment,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),

          const SizedBox(height: 5),

          Divider(color: Theme.of(context).colorScheme.surface),

          // Like, Comment and Date
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => toggleLike(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                    // const SizedBox(width: 5),
                    Text(
                      likeCount.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('yyyy-MM-dd  HH:mm')
                      .format(widget.comment.timestamp.toDate()),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
