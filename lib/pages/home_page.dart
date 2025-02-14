import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/components/my_drawer.dart';
import 'package:minimal_tweets_app/components/post_card.dart';
import 'package:minimal_tweets_app/services/auth/auth_service.dart';
import 'package:minimal_tweets_app/services/post/post_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final auth = AuthService();

  final postController = TextEditingController();

  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadAllPosts();
  }

  Future<void> loadAllPosts() async {
    await databaseProvider.fetchAllPosts();
  }

  void postSomething() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 220,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: TextField(
              controller: postController,
              maxLength: 200,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
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

            // Post
            MaterialButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await databaseProvider.postPost(postController.text);
                postController.clear();
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

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = listeningProvider.posts;
    final followingPosts = listeningProvider.followingPosts;

    return Scaffold(
      appBar: AppBar(
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
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => postSomething(),
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Tabs
            TabBar(
              controller: tabController,
              padding: EdgeInsets.all(16.0),
              indicatorColor: Theme.of(context).colorScheme.tertiary,
              dividerColor: Theme.of(context).colorScheme.surface,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.secondary,
              tabs: [Tab(text: 'For you'), Tab(text: 'Following')],
            ),

            // TabScreens
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  // For You Posts
                  posts.isEmpty
                      ? Center(child: Text('Loading'))
                      : ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return PostCard(
                              post: posts[index],
                              index: index,
                            );
                          },
                        ),

                  // Following Posts
                  followingPosts.isEmpty
                      ? Center(child: Text('Loading...'))
                      : ListView.builder(
                          itemCount: followingPosts.length,
                          itemBuilder: (context, index) {
                            return PostCard(
                              post: followingPosts[index],
                              index: index,
                            );
                          },
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
