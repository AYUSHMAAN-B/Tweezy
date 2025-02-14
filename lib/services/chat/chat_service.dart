import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SEND MESSAGE
  Future<void> sendMessage(String receiverId, String message) async {
    final String senderId = _auth.currentUser!.uid;
    final String senderEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message messageToSend = Message(
      senderId: senderId,
      senderEmail: senderEmail,
      recieverId: receiverId,
      message: message,
      seen: false,
      timestamp: timestamp,
    );

    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageToSend.toMap());
  }

  // DELETE MESSAGE
  Future<void> deleteMessage(String receiverId, String msgId) async {
    final String senderId = _auth.currentUser!.uid;

    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(msgId)
        .delete();
  }

  // GET ALL MESSAGES
  Stream<QuerySnapshot> getAllMessages(String senderId, String recieverId) {
    List<String> ids = [senderId, recieverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // MARK MESSAGES AS SEEN
  Future<void> markMessagesAsSeen(String receiverId) async {
    final chatRoom = [_auth.currentUser!.uid, receiverId]..sort();
    final chatRoomId = chatRoom.join('_');

    final userSnapshot = await _firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('seen', isEqualTo: false)
        .get();

    for (var doc in userSnapshot.docs) {
      await doc.reference.update({'seen': true});
    }
  }
}
