import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/pages/auth_page.dart';
import 'package:minimal_tweets_app/pages/home_page.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if( snapshot.hasData ) {
            return HomePage();
          } else {
            return AuthPage();
          }
        }
      ),
    );
  }
}