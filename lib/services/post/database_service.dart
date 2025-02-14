import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minimal_tweets_app/models/comment.dart';
import 'package:minimal_tweets_app/models/post.dart';
import 'package:minimal_tweets_app/models/user.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /*
  
  P O S T S

  */

  // POST POST
  Future<void> addNewPostToFirestore(String post) async {
    try {
      final userMap = await getUserInfoFromFirestore(_auth.currentUser!.uid);
      final user = UserProfile.fromDocument(userMap);

      final newPost = Post(
        id: '',
        post: post,
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        userPhoto: user.photo,
        likeCount: 0,
        likedBy: [],
        timestamp: Timestamp.now(),
      );

      await _firestore.collection('posts').add(newPost.toMap());
    } catch (e) {
      print(e);
    }
  }

  // EDIT POST
  Future<void> editPostInFirestore(String post, String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'post': post,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }

  // DELETE POST
  Future<void> deletePostInFirestore(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

  // GET ALL POSTS
  Future<List<Post>> getAllPostsFromFirestore() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  /*
  
  L I K E S
  
  */

  Future<void> toggleLikeForPostInFirestore(String postId) async {
    try {
      String userId = _auth.currentUser!.uid;

      DocumentReference postDoc = _firestore.collection('posts').doc(postId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);

        List<String> likedBy = List<String>.from(postSnapshot['likedBy'] ?? []);

        int currentLikeCount = postSnapshot['likes'];

        if (!likedBy.contains(userId)) {
          likedBy.add(userId);
          currentLikeCount++;
        } else {
          likedBy.remove(userId);
          currentLikeCount--;
        }

        transaction.update(postDoc, {
          'likes': currentLikeCount,
          'likedBy': likedBy,
        });
      });
    } catch (e) {
      print(e);
    }
  }

  /*
  
  C O M M E N T S
  
  */

  // COMMENT ON POST
  Future<void> addCommentToFirestore(Comment comment, String postId) async {
    try {
      // Add Comment In Firestore
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add(comment.toMap());

      // Increment Count For Post
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });
    } catch (e) {
      print(e);
    }
  }

  // LIKE - UNLIKE A COMMENT
  Future<void> toggleLikeCommentInFirestore(
    String postId,
    String commentId,
  ) async {
    try {
      final userId = _auth.currentUser!.uid;

      DocumentReference commentDoc = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot commentSnapshot = await transaction.get(commentDoc);

        List<String> likedBy =
            List<String>.from(commentSnapshot['likedBy'] ?? []);

        int currentLikeCount = commentSnapshot['likes'];

        if (!likedBy.contains(userId)) {
          likedBy.add(userId);
          currentLikeCount++;
        } else {
          likedBy.remove(userId);
          currentLikeCount--;
        }

        transaction.update(commentDoc, {
          'likes': currentLikeCount,
          'likedBy': likedBy,
        });
      });
    } catch (e) {
      print(e);
    }
  }

  // EDIT COMMENET
  Future<void> editCommentInFirestore(
    String postId,
    String commentId,
    String comment,
  ) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }

  // GET COMMENTS FOR A POST
  Future<List<Comment>> getCommentsForPostFromFirestore(String postId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get();

      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // DELETE COMMENT
  Future<void> deleteCommentInFirestore(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(-1),
      });
    } catch (e) {
      print(e);
    }
  }

  /*
  
  F  O L L O W   -   U N F O L L O W
  
  */

  // FOLLOW USER
  Future<void> followUserInFirestore(String targetUserId) async {
    final currentUserId = _auth.currentUser!.uid;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .set({});

      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .set({});
    } catch (e) {
      print(e);
    }
  }

  // UNFOLLOW USER
  Future<void> unFollowUserInFirestore(String targetUserId) async {
    final currentUserId = _auth.currentUser!.uid;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .delete();

      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  // GET FOLLOWING USERS POST
  Future<List<Post>> getFollowingUsersPostFromFirestore() async {
    // Get the list of users the current user is following
    var followingSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('following')
        .get();

    List<String> followingUsers =
        followingSnapshot.docs.map((doc) => doc.id).toList();

    // Fetch posts from Firestore
    var postsSnapshot = await _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .get();

    // Filter posts to include only those from following users
    List<Post> posts = postsSnapshot.docs
        .where((doc) => followingUsers.contains(doc['userId']))
        .map((doc) => Post.fromDocument(doc))
        .toList();

    return posts;
  }

  // FETCH USER'S FOLLOWERS
  Future<List<String>> getUsersFollowersFromFirestore(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  // FETCH USER'S FOLLOWING
  Future<List<String>> getUsersFollowingFromFirestore(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  /*
  
  U S E R

  */

  // UPDATE BIO
  Future<void> updateBioInFirestore(String bio) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('users').doc(uid).update({'bio': bio});
  }

  // REPORT USER
  Future<void> reportUserInFirestore(String userId, String postId) async {
    await _firestore.collection('report').add({
      'reportedBy': _auth.currentUser!.uid,
      'reportedUserId': userId,
      'reportedPostId': postId,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  // BLOCK USER
  Future<List<String>> blockUserInFirestore(String userId) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('blocked')
        .doc(userId)
        .set({'timestamp': FieldValue.serverTimestamp()});

    QuerySnapshot blockedSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('blocked')
        .get();

    return blockedSnapshot.docs.map((doc) => doc.id).toList();
  }

  // UNBLOCK USER
  Future<List<String>> unBlockUserInFirestore(String userId) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('blocked')
        .doc(userId)
        .delete();

    QuerySnapshot blockedSnapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('blocked')
        .get();

    return blockedSnapshot.docs.map((doc) => doc.id).toList();
  }

  // GET USER INFORMATION
  Future<DocumentSnapshot> getUserInfoFromFirestore(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // GET BLOCKED USERS
  Stream<List<UserProfile>> getBlockedUsersFromFirestore() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('blocked')
        .snapshots()
        .asyncMap(
      (snapshot) async {
        final blocked = snapshot.docs.map((doc) => doc.id).toList();

        final users = await Future.wait(
          blocked.map((id) => _firestore.collection('users').doc(id).get()),
        );

        return users.map((doc) => UserProfile.fromDocument(doc)).toList();
      },
    );
  }
}
