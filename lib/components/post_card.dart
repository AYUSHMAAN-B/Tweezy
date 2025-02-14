import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimal_tweets_app/models/post.dart';
import 'package:minimal_tweets_app/pages/comments_page.dart';
import 'package:minimal_tweets_app/pages/profile_page.dart';
import 'package:minimal_tweets_app/services/auth/auth_service.dart';
import 'package:minimal_tweets_app/services/post/post_service.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final int index;
  final bool? goTo;

  const PostCard({
    super.key,
    required this.post,
    required this.index,
    this.goTo,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final postController = TextEditingController();

  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  void loadComments() async {
    await databaseProvider.fetchCommentsForPost(widget.post.id);
  }

  void toggleLike() async {
    await databaseProvider.toggleLikePost(widget.post.id);
  }

  void editDialog(bool post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: post == true ? 220 : 150,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: TextField(
              controller: postController,
              maxLength: post == true ? 200 : 100,
              maxLines: post == true ? 7 : 5,
              decoration: InputDecoration(
                hintText: post == true
                    ? 'What\'s on your mind?'
                    : 'What\'s your take?',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
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
                postController.clear();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            MaterialButton(
              onPressed: () async {
                Navigator.of(context).pop();
                post == true
                    ? databaseProvider.editPost(
                        postController.text, widget.post.id)
                    : databaseProvider.commentOnPost(
                        postController.text, widget.post.id);
                postController.clear();
              },
              child: Text(
                'Done',
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
                        widget.post.userId, widget.post.id);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Block User'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await databaseProvider.blockUser(widget.post.userId);
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
    bool liked = listeningProvider.isPostLikedByCurrentUser(widget.post.id);
    int likeCount = listeningProvider.getLikeCount(widget.post.id);
    int commentCount =
        listeningProvider.getCommentsForPost(widget.post.id).length;

    return GestureDetector(
      onTap: () {
        if (widget.goTo == null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return CommentsPage(post: widget.post);
              },
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: widget.index == 9
            ? EdgeInsets.only(bottom: 100.0)
            : EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Info
                  Row(
                    children: [
                      // User Photo
                      widget.post.userPhoto != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              child: Image.network(
                                widget.post.userPhoto!,
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
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ProfilePage(userId: widget.post.userId);
                          }));
                        },
                        child: Text(
                          widget.post.userName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
              
                      // @
                      Text(
                        '@${widget.post.userEmail.split('@')[0]}',
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
                          if (widget.post.userId ==
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
                                          postController.text = widget.post.post;
                                          Navigator.of(context).pop();
                                          editDialog(true);
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
                                          await databaseProvider
                                              .deletePost(widget.post.id);
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
              constraints: BoxConstraints(maxHeight: 80),
              child: Text(
                widget.post.post,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),

            const SizedBox(height: 5),

            Divider(color: Theme.of(context).colorScheme.surface),

            // Like, Comment and Date
            SizedBox(
              height: 25,
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
                      Text(
                        likeCount.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => editDialog(false),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Icon(
                            Icons.message,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        commentCount.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd  HH:mm')
                        .format(widget.post.timestamp.toDate()),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
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
