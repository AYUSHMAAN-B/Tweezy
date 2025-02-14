import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  String comment;
  final String postId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhoto;
  final List<String> likedBy;
  Timestamp timestamp;

  Comment({
    required this.id,
    required this.comment,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhoto,
    required this.likedBy,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      id: doc.id,
      comment: doc['comment'],
      postId: doc['postId'],
      userId: doc['userId'],
      userName: doc['userName'],
      userEmail: doc['userEmail'],
      userPhoto: doc['userPhoto'],
      likedBy: List<String>.from(doc['likedBy']),
      timestamp: doc['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'comment': comment,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhoto': userPhoto,
      'likedBy': likedBy,
      'timestamp': timestamp,
    };
  }
}
