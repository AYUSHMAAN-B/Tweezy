import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/pages/profile_page.dart';
import 'package:minimal_tweets_app/pages/search_page.dart';
import 'package:minimal_tweets_app/pages/settings_page.dart';
import 'package:minimal_tweets_app/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.getCurrentUser();

    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(height: 100),

              // Icon
              if (user != null)
                user.photoURL != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        child: Image.network(user.photoURL!))
                    : Icon(
                        Icons.person,
                        size: 100,
                        color: Theme.of(context).colorScheme.secondary,
                      ),

              const SizedBox(height: 50),

              Divider(
                height: 8,
                color: Theme.of(context).colorScheme.tertiary,
                indent: 35,
                endIndent: 35,
              ),

              const SizedBox(height: 25),

              // HOME
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36.0, vertical: 2.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'H O M E',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // PROFILE
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return ProfilePage(userId: auth.getCurrentUser()!.uid);
                    }),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36.0, vertical: 2.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'P R O F I L E',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // SEARCH
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return SearchPage();
                    }),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36.0, vertical: 2.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'S E A R C H',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // SETTINGS
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return SettingsPage();
                  }));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36.0, vertical: 2.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'S E T T I N G S',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // LOG OUT
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                auth.signOut();
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 36.0, vertical: 2.0),
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      'L O G   O U T',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
