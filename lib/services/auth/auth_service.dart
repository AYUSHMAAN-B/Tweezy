import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minimal_tweets_app/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // SignUp
  Future<UserCredential> signUpWithEmailAndPassword(
      String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserProfile newUser = UserProfile(
        id: '',
        name: name,
        email: email,
        photo: null,
        bio: null,
        followers: 0,
        following: 0,
      );

      _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toMap());

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Google SignIn
  Future<UserCredential?> signInUsingGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Ensure the previous session is cleared to force account selection
      await googleSignIn.signOut();

      // Start Google Sign-In process
      final GoogleSignInAccount? gUser = await googleSignIn.signIn();

      if (gUser == null) {
        throw Exception("Google Sign-In canceled by user");
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      UserProfile newUser = UserProfile(
        id: '',
        name: userCredential.user!.displayName ?? 'Null Name',
        email: userCredential.user!.email ?? 'Null Email',
        photo: userCredential.user!.photoURL,
        bio: null,
        followers: 0,
        following: 0,
      );

      // Store user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(
        newUser.toMap(),
        SetOptions(merge: true),
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Firebase Auth Error: ${e.message}");
    } on Exception catch (e) {
      throw Exception("Google Sign-In Error: ${e.toString()}");
    }
  }

  // SignIn
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // SignOut
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<void> forgotPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    final user = getCurrentUser();

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    }
  }
}
