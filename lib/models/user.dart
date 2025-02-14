import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String id;
  final String name;
  final String email;
  final String? photo;
  String? bio;
  final int followers;
  final int following;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.photo,
    required this.bio,
    required this.followers,
    required this.following,
  });

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(
      id: doc.id,
      name: doc['name'],
      email: doc['email'],
      photo: doc['photo'],
      bio: doc['bio'],
      followers: doc['followers'],
      following: doc['following'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name' : name,
      'email' : email,
      'photo' : photo,
      'bio' : bio,
      'followers' : followers,
      'following' : following,
    };
  }
}
