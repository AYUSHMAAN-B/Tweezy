import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/components/post_card.dart';
import 'package:minimal_tweets_app/models/user.dart';
import 'package:minimal_tweets_app/pages/chat_page.dart';
import 'package:minimal_tweets_app/services/auth/auth_service.dart';
import 'package:minimal_tweets_app/services/post/post_service.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final bioController = TextEditingController();

  final auth = AuthService();
  UserProfile? user;

  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  bool isLoading = false;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.getUserInfo(widget.userId);
    isFollowing = databaseProvider.isFollowingUser(widget.userId);

    await databaseProvider.getUsersFollowers(widget.userId);
    await databaseProvider.getUsersFollowing(widget.userId);

    setState(() {
      isLoading = false;
    });
  }

  void editBio() {
    showDialog(
      context: context,
      builder: (context) {
        if (user!.bio != null) {
          bioController.text = user!.bio!;
        }

        return AlertDialog(
          content: Container(
            height: 120,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: TextField(
              controller: bioController,
              maxLength: 100,
              maxLines: 4,
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
                bioController.clear();
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
                setState(() {
                  isLoading = true;
                });
                Navigator.of(context).pop();
                await databaseProvider.updateBio(bioController.text);
                bioController.clear();
                // await loadUser();
                setState(() {
                  isLoading = false;
                });
              },
              child: Text(
                'Save',
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
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPosts = listeningProvider.getUserPosts(widget.userId);
    final followersCount = listeningProvider.getFollowerCount(widget.userId);
    final followingCount = listeningProvider.getFollowingCount(widget.userId);

    isFollowing = listeningProvider.isFollowingUser(widget.userId);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          isLoading == true ? 'Loading...' : user!.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    recieverId: user!.id,
                    recieverName: user!.name,
                    recieverEmail: user!.email,
                  ),
                ),
              );
            },
            icon: Icon(Icons.message),
            padding: EdgeInsets.only(right: 16.0),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // @
              Text(
                '@${isLoading == true ? 'Loading...' : user!.email.split('@')[0]}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Person Icon
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: isLoading == true
                    ? Icon(Icons.person)
                    : user!.photo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            child: Image.network(user!.photo!))
                        : Icon(
                            Icons.person,
                            size: 100,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
              ),

              const SizedBox(height: 15),

              // Account Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        userPosts.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        'Posts',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        isLoading == true
                            ? 'Loading...'
                            : followersCount.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        'Followers',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        isLoading == true
                            ? 'Loading...'
                            : followingCount.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        'Following',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Follow - UnFollow
              if (widget.userId != AuthService().getCurrentUser()!.uid)
                GestureDetector(
                  onTap: () async {
                    if (isFollowing) {
                      await databaseProvider.unFollowUser(widget.userId);
                    } else {
                      await databaseProvider.followUser(widget.userId);
                    }

                    setState(() {
                      isFollowing = !isFollowing;
                    });
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    margin: EdgeInsets.all(16.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isFollowing
                          ? Colors.blue
                          : Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Center(
                      child: Text(
                        isFollowing ? 'F O L L O W I N G' : 'F O L L O W',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),

              // Edit Bio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bio',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.userId == AuthService().getCurrentUser()!.uid)
                      IconButton(
                        onPressed: () => editBio(),
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                  ],
                ),
              ),

              // Bio
              Container(
                height: 100,
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Text(
                  isLoading == true ? 'Loading...' : user!.bio ?? 'NULL',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Posts Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Posts',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Posts
              userPosts.isEmpty
                  ? Center(child: Text('He didn\'t post anything yet.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: userPosts.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          post: userPosts[index],
                          index: index,
                        );
                      },
                    ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
