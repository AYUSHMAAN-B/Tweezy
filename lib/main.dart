import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/firebase_options.dart';
import 'package:minimal_tweets_app/pages/initial_page.dart';
import 'package:minimal_tweets_app/services/post/post_service.dart';
import 'package:minimal_tweets_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => DatabaseProvider()),
    ], child: const MyApp(),)
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      debugShowCheckedModeBanner: false,
      home: InitialPage(),
    );
  }
}

/*

-------------------- T W E E Z Y --------------------

A simple twitter clone made with flutter. It has various features.

- Firebase Authentication
- Cloud Database
- User can post whatever he want.
- User can like / unlike a post.
- User can comment on a post.
- User can edit / delete his posts.
- User can search for other users.
- User can message other users.
- User can follow other users.
- User can report others posts.
- User can block other users.

*/

