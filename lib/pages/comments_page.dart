import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/components/comment_card.dart';
import 'package:minimal_tweets_app/components/post_card.dart';
import 'package:minimal_tweets_app/models/post.dart';
import 'package:minimal_tweets_app/services/post/post_service.dart';
import 'package:provider/provider.dart';

class CommentsPage extends StatefulWidget {
  final Post post;

  const CommentsPage({
    super.key,
    required this.post,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final postController = TextEditingController();

  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final comments = listeningProvider.getCommentsForPost(widget.post.id);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.post.userName),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () => setState(() {}),
              icon: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Post
              PostCard(post: widget.post, index: 0, goTo: false),

              Divider(height: 2),

              // Comments
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return CommentCard(
                    comment: comments[index],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
