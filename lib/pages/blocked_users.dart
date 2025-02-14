import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/models/user.dart';
import 'package:minimal_tweets_app/services/post/post_service.dart';
import 'package:provider/provider.dart';

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({super.key});

  @override
  State<BlockedUsers> createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {

  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

  void unBlockDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure you want to unBlock this user?'),
          actions: [
            // Cancel
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            // Sure
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
                databaseProvider.unBlockUser(userId);
              },
              child: Text(
                'Yes',
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('B L O C K E D   U S E R S'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: DatabaseProvider().getBlockedUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading Blocked Users');
          }

          if (snapshot.hasError) {
            return Text("Error : ${snapshot.error}");
          }

          List<UserProfile>? blockedUsers = snapshot.data;

          if (blockedUsers == null) {
            return Text('No Blocked Users');
          }

          if (blockedUsers.isEmpty) {
            return Center(child: Text('No Users blocked till now.'));
          }

          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              return Container(
                height: 75,
                width: double.infinity,
                margin: EdgeInsets.all(16.0),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        blockedUsers[index].name,
                      ),
                    ),
                    IconButton(
                      onPressed: () => unBlockDialog(blockedUsers[index].id),
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
