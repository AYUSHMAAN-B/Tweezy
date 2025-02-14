import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String recieverId;
  final String message;
  final bool seen;
  final Timestamp timestamp;

  const Message({
    required this.senderId,
    required this.senderEmail,
    required this.recieverId,
    required this.message,
    required this.seen,
    required this.timestamp
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId' : senderId,
      'senderEmail' : senderEmail,
      'recieverId' : recieverId,
      'message' : message,
      'seen' : seen,
      'timestamp' : timestamp
    };
  }
}