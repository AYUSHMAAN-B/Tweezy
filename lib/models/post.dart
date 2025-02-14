import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  String post;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhoto;
  final int likeCount;
  final List<String> likedBy;
  Timestamp timestamp;

  Post({
    required this.id,
    required this.post,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhoto,
    required this.likeCount,
    required this.likedBy,
    required this.timestamp,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      userId: data['userId'],
      userName: data['userName'],
      userEmail: data['userEmail'],
      userPhoto: data['userPhoto'],
      post: data['post'],
      likeCount: data['likes'],
      likedBy: List<String>.from(data['likedBy'] ?? []),
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post': post,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhoto': userPhoto,
      'likes' : likeCount,
      'likedBy': likedBy,
      'timestamp': timestamp,
    };
  }
}
