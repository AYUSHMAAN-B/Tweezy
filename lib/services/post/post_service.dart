import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/models/comment.dart';
import 'package:minimal_tweets_app/models/post.dart';
import 'package:minimal_tweets_app/models/user.dart';
import 'package:minimal_tweets_app/services/post/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _db = DatabaseService();

  /*
  
  P O S T S
  
  */

  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];

  List<Post> get posts => _allPosts;
  List<Post> get followingPosts => _followingPosts;

  // FETCH ALL POSTS
  Future<void> fetchAllPosts() async {
    try {
      // Get all Posts from firebase
      final allPosts = await _db.getAllPostsFromFirestore();

      // Store them in local storage
      _allPosts = allPosts;

      // Initialize Like Map
      initializeLikeMap();

      // Fill other local storages.
      await getUsersFollowers(_auth.currentUser!.uid);
      await getUsersFollowing(_auth.currentUser!.uid);

      // Add following posts to local storage
      _followingPosts.clear();
      for (var post in _allPosts) {
        if (isFollowingUser(post.userId)) {
          _followingPosts.add(post);
        }
      }

      // Update UI.
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // GET USER POSTS
  List<Post> getUserPosts(String userId) {
    return _allPosts.where((post) => post.userId == userId).toList();
  }

  // GET FOLLOWING POST
  Future<List<Post>> getFollowingUsersPost() {
    return _db.getFollowingUsersPostFromFirestore();
  }

  // POST POST
  Future<void> postPost(String post) async {
    try {
      // Add Post To Firestore
      await _db.addNewPostToFirestore(post);

      // Fetch All Posts
      final allPosts = await _db.getAllPostsFromFirestore();

      // Update Local Storage
      _allPosts = allPosts;

      // Update UI
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // EDIT POST
  Future<void> editPost(String post, String postId) async {
    final before = _allPosts;

    try {
      int postIndex = _allPosts.indexWhere((post) => post.id == postId);

      // Update Local Storage
      _allPosts[postIndex].post = post;
      _allPosts[postIndex].timestamp = Timestamp.now();

      // Update UI
      notifyListeners();

      await _db.editPostInFirestore(post, postId);
    }

    // Catch Error
    catch (e) {
      // Rollback
      _allPosts = before;
    }
  }

  // DELETE POST
  Future<void> deletePost(String postId) async {
    final before = _allPosts;

    try {
      int postIndex = _allPosts.indexWhere((post) => post.id == postId);

      // Update Local Storage
      _allPosts.removeAt(postIndex);

      // Update UI
      notifyListeners();

      // Update Firestore
      await _db.deletePostInFirestore(postId);
    }

    // Catch Error
    catch (e) {
      // Rollback
      _allPosts = before;
    }
  }

  /*
  
  L I K E S
  
  */

  Map<String, int> _likeCounts = {};
  List<String> _likedPosts = [];

  Map<String, int> get likeCounts => _likeCounts;
  List<String> get likedPosts => _likedPosts;

  // INITIALIZE LIKE LOCAL STORAGE
  void initializeLikeMap() {
    String userId = _auth.currentUser!.uid;

    _likedPosts.clear();

    _followingPosts.clear();
    for (var post in _allPosts) {
      _likeCounts[post.id] = post.likeCount;

      if (post.likedBy.contains(userId)) {
        likedPosts.add(post.id);
      }
    }
  }

  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;

  // LIKE - UNLIKE A POST
  Future<void> toggleLikePost(String postId) async {
    // Store Originals For Rollcack
    final likedPostsOriginal = _likedPosts;
    final likeCountsOriginal = _likeCounts;

    try {
      // Update In Local Storage
      if (_likedPosts.contains(postId)) {
        _likedPosts.remove(postId);
        _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
      } else {
        _likedPosts.add(postId);
        _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
      }

      // Update UI
      notifyListeners();

      // Update In Firestore
      await _db.toggleLikeForPostInFirestore(postId);
    }

    // Catch Error
    catch (e) {
      print(e);

      // Rollback
      _likedPosts = likedPostsOriginal;
      _likeCounts = likeCountsOriginal;

      // Update UI
      notifyListeners();
    }
  }

  /*
  
  C O M M E N T S
  
  */

  Map<String, List<Comment>> _comments = {};

  Map<String, List<Comment>> get comments => _comments;

  // FETCH COMMENTS FOR A POST
  Future<void> fetchCommentsForPost(String postId) async {
    try {
      // Get comments from firestore
      final comments = await _db.getCommentsForPostFromFirestore(postId);

      // Store them in local storage
      _comments[postId] = comments;

      // Update UI
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // GET COMMENTS FOR A POST
  List<Comment> getCommentsForPost(String postId) => _comments[postId] ?? [];

  // COMMENT ON POST
  Future<void> commentOnPost(String comment, String postId) async {
    UserProfile user = await getUserInfo(_auth.currentUser!.uid);

    // Store For Rollback
    final beforeComments = _comments;
    final beforePosts = _allPosts;

    try {
      Comment newComment = Comment(
        id: '',
        comment: comment,
        postId: postId,
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        userPhoto: user.photo,
        likedBy: [],
        timestamp: Timestamp.now(),
      );

      // Update In Local Storage
      if (_comments[postId] == null) {
        _comments[postId] = [newComment];
      } else {
        _comments[postId]!.add(newComment);
      }

      // Update UI
      notifyListeners();

      // Update In Firestore
      await _db.addCommentToFirestore(newComment, postId);
    }

    // Catch Error
    catch (e) {
      // Rollback
      _comments = beforeComments;
      _allPosts = beforePosts;
    }
  }

  // LIKE - UNLIKE A COMMENT
  Future<void> toggleLikeComment(String postId, String commentId) async {
    final userId = _auth.currentUser!.uid;

    // Store For Rollback
    final before = _comments[postId];

    try {
      int commentIndex =
          _comments[postId]!.indexWhere((comment) => comment.id == commentId);

      bool isLiked = _comments[postId]![commentIndex].likedBy.contains(userId);

      // Update Local Storage
      if (isLiked) {
        _comments[postId]![commentIndex].likedBy.remove(userId);
      } else {
        _comments[postId]![commentIndex].likedBy.add(userId);
      }

      // Update UI
      notifyListeners();

      await _db.toggleLikeCommentInFirestore(postId, commentId);
    }

    // Catch error
    catch (e) {
      // Roll Back
      _comments[postId] = before!;

      print(e);
    }
  }

  // EDIT COMMENET
  Future<void> editComment(
    String postId,
    String commentId,
    String comment,
  ) async {
    // Save Original For Rollback
    final before = _comments[postId];

    try {
      int commentIndex = _comments[postId]!.indexWhere(
          (comment) => (comment.postId == postId && comment.id == commentId));

      // Update In Local Storage
      _comments[postId]![commentIndex].comment = comment;
      _comments[postId]![commentIndex].timestamp = Timestamp.now();

      // Update UI
      notifyListeners();

      await _db.editCommentInFirestore(postId, commentId, comment);
    }

    // Catch Error
    catch (e) {
      // Rollback
      _comments[postId] = before!;
    }
  }

  // DELETE COMMENT
  Future<void> deleteComment(String postId, String commentId) async {
    final beforeComments = _comments[postId];
    final beforePosts = _allPosts;

    try {
      int commentIndex =
          _comments[postId]!.indexWhere((comment) => comment.id == commentId);
      _comments[postId]!.removeAt(commentIndex);

      notifyListeners();

      await _db.deleteCommentInFirestore(postId, commentId);
    } catch (e) {
      print(e);
      _comments[postId] = beforeComments!;
      _allPosts = beforePosts;
    }
  }

  /*
  
  F O L L O W   -   U N F O L L O W
  
  */

  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};

  Map<String, List<String>> get followers => _followers;
  Map<String, List<String>> get following => _following;
  Map<String, int> get followerCount => _followerCount;
  Map<String, int> get followingCount => _followingCount;

  // FOLLOW USER
  Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.currentUser!.uid;

    try {
      _followers.putIfAbsent(targetUserId, () => []);
      _following.putIfAbsent(currentUserId, () => []);

      // Update Local Storage
      if (!_followers[targetUserId]!.contains(currentUserId)) {
        _followers[targetUserId]!.add(currentUserId);

        _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

        _following[currentUserId]!.add(targetUserId);

        _followingCount[currentUserId] =
            (_followingCount[currentUserId] ?? 0) + 1;
      }

      // Update UI
      notifyListeners();

      // Update Firestore
      await _db.followUserInFirestore(targetUserId);

      // Add following posts to local storage
      _followingPosts.clear();
      for (var post in _allPosts) {
        if (isFollowingUser(post.userId)) {
          _followingPosts.add(post);
        }
      }

      // Update UI
      notifyListeners();
    } catch (e) {
      print(e);

      // Rollback
      _followers[targetUserId]!.remove(currentUserId);

      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) - 1;

      _following[currentUserId]!.remove(targetUserId);

      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) - 1;

      // Add following posts to local storage
      _followingPosts.clear();
      for (var post in _allPosts) {
        if (isFollowingUser(post.userId)) {
          _followingPosts.add(post);
        }
      }

      // Update UI
      notifyListeners();
    }
  }

  // UNFOLLOW USER
  Future<void> unFollowUser(String targetUserId) async {
    final currentUserId = _auth.currentUser!.uid;

    try {
      _followers.putIfAbsent(targetUserId, () => []);
      _following.putIfAbsent(currentUserId, () => []);

      // Update Local Storage
      if (_following[currentUserId]!.contains(targetUserId)) {
        _followers[targetUserId]!.remove(currentUserId);

        _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) - 1;

        _following[currentUserId]!.remove(targetUserId);

        _followingCount[currentUserId] =
            (_followingCount[currentUserId] ?? 0) - 1;
      }

      // Update UI
      notifyListeners();

      await _db.unFollowUserInFirestore(targetUserId);

      // Add following posts to local storage

      _followingPosts.clear();
      for (var post in _allPosts) {
        if (isFollowingUser(post.userId)) {
          _followingPosts.add(post);
        }
      }

      // Update UI
      notifyListeners();
    } catch (e) {
      print(e);

      // Rollback
      _followers[targetUserId]!.add(currentUserId);

      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      _following[currentUserId]!.add(targetUserId);

      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;

      // Add following posts to local storage
      _followingPosts.clear();
      for (var post in _allPosts) {
        if (isFollowingUser(post.userId)) {
          _followingPosts.add(post);
        }
      }

      // Update UI
      notifyListeners();
    }
  }

  // FETCH USER'S FOLLOWERS
  Future<void> getUsersFollowers(String userId) async {
    // Fetch From Firestore
    List<String> followers = await _db.getUsersFollowersFromFirestore(userId);

    // Update Local Storage
    _followers[userId] = followers;
    _followerCount[userId] = followers.length;

    // Update UI
    notifyListeners();
  }

  // FETCH USER'S FOLLOWING
  Future<void> getUsersFollowing(String userId) async {
    // Fetch From Firestore
    List<String> following = await _db.getUsersFollowingFromFirestore(userId);

    // Update Local Storage
    _following[userId] = following;
    _followingCount[userId] = following.length;

    // Update UI
    notifyListeners();
  }

  int getFollowerCount(String userId) => _followerCount[userId] ?? 0;
  int getFollowingCount(String userId) => _followingCount[userId] ?? 0;
  bool isFollowingUser(String userId) =>
      _following[_auth.currentUser!.uid]?.contains(userId) ?? false;

  /*
  
  U S E R

  */

  // GET USER INFO
  Future<UserProfile> getUserInfo(String userId) async {
    final userDoc = await _db.getUserInfoFromFirestore(userId);
    return UserProfile.fromDocument(userDoc);
  }

  // GET BLOCKED USERS
  Stream<List<UserProfile>> getBlockedUsers() {
    return _db.getBlockedUsersFromFirestore();
  }

  // UPDATE BIO
  Future<void> updateBio(String bio) async {
    // Update In Firestore
    await _db.updateBioInFirestore(bio);

    // Update UI
    notifyListeners();
  }

  // REPORT USER
  Future<void> reportUser(String userId, String postId) async {
    await _db.reportUserInFirestore(userId, postId);
  }

  // BLOCK USER
  Future<void> blockUser(String userId) async {
    // Block User In Firestore And Get Blocked IDs
    List<String> blockedUids = await _db.blockUserInFirestore(userId);

    // Update Posts In Local Storgae
    _allPosts = _allPosts.where((post) => !blockedUids.contains(post.userId)).toList();
    _followingPosts = _followingPosts.where((post) => !blockedUids.contains(post.userId)).toList();

    // Initialize Like Map Again
    initializeLikeMap();

    // Update UI
    notifyListeners();
  }

  // UNBLOCK USER
  Future<void> unBlockUser(String userId) async {
    // Unblock User In Firestore
    List<String> blockedUids = await _db.unBlockUserInFirestore(userId);

    await fetchAllPosts();

    // Update Posts In Local Storgae
    _allPosts = _allPosts.where((post) => !blockedUids.contains(post.userId)).toList();
    _followingPosts = _followingPosts.where((post) => !blockedUids.contains(post.userId)).toList();

    // Initialize Like Map Again
    initializeLikeMap();

    // Update UI
    notifyListeners();
  }
}
