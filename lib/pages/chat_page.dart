// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimal_tweets_app/components/my_text_field.dart';
import 'package:minimal_tweets_app/pages/home_page.dart';
import 'package:minimal_tweets_app/services/auth/auth_service.dart';
import 'package:minimal_tweets_app/services/chat/chat_service.dart';
import 'package:minimal_tweets_app/services/post/post_service.dart';

class ChatPage extends StatefulWidget {
  final String recieverId;
  final String recieverName;
  final String recieverEmail;

  const ChatPage({
    super.key,
    required this.recieverId,
    required this.recieverName,
    required this.recieverEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final AuthService auth = AuthService();
  final ChatService firestore = ChatService();
  final DatabaseProvider db = DatabaseProvider();

  final messageController = TextEditingController();

  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 500), () => scrollDown());
      }
    });

    Future.delayed(Duration(milliseconds: 200), () {
      scrollDown();
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  final ScrollController scrollController = ScrollController();

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Show Bottom Sheet for Options
  void showBottomSheetLayout(
      BuildContext context, String userId, String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.report),
                  title: Text('Report User'),
                  onTap: () {
                    Navigator.of(context).pop();
                    reportUser(userId, messageId);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Block User'),
                  onTap: () {
                    Navigator.of(context).pop();
                    blockUser(userId);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel),
                  title: Text('Cancel User'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Report User
  void reportUser(String userId, String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Do you want to report this user?'),
          actions: [
            // Cancel
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),

            // Report
            MaterialButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await db.reportUser(userId, messageId);
              },
              child: Text('Report'),
            ),
          ],
        );
      },
    );
  }

  // Block User
  void blockUser(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Do you want to block this user?'),
          actions: [
            // Cancel
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),

            // Report
            MaterialButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                await db.blockUser(userId);
              },
              child: Text('Block'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => route.isFirst,
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(widget.recieverName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          MessagesList(
              auth.getCurrentUser()!.uid, widget.recieverId, firestore),
          ChatBox(widget.recieverId, firestore)
        ],
      ),
    );
  }

  // List of Messages
  Widget MessagesList(
    String senderId,
    String recieverId,
    ChatService firestore,
  ) {
    return Expanded(
      child: StreamBuilder(
        stream: firestore.getAllMessages(
          senderId,
          recieverId,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error...');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading Chats...');
          }

          return ListView(
            controller: scrollController,
            children: snapshot.data!.docs
                .map((document) => MessageItem(
                      senderId,
                      recieverId,
                      context,
                      document,
                      firestore,
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  // Individual MessageItem
  Widget MessageItem(
    String senderId,
    String recieverId,
    BuildContext context,
    DocumentSnapshot document,
    ChatService firestore,
  ) {
    final message = document.data() as Map<String, dynamic>;
    int timestamp = (message['timestamp'] as Timestamp).seconds;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final timeStamp = DateFormat('yyyy-MM-dd HH:mm').format(date);

    bool isUser() {
      return senderId == message['senderId'];
    }

    return GestureDetector(
      onLongPress: () {
        if (!isUser()) {
          showBottomSheetLayout(context, recieverId, document.id);
        }
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isUser() ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isUser()
                          ? Colors.lightGreen
                          : Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      message['message'],
                      softWrap: true,
                      style: TextStyle(
                          color: isUser()
                              ? Colors.white
                              : Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment:
                  isUser() ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  timeStamp,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // TextField for Message
  Widget ChatBox(String recieverId, ChatService firestore) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: messageController,
              icon: Icons.keyboard,
              hintText: 'Type Here',
              obscureText: false,
              focusNode: myFocusNode,
            ),
          ),
          IconButton(
            onPressed: () async {
              if (messageController.text.isNotEmpty) {
                String msg = messageController.text;
                messageController.clear();
                await firestore.sendMessage(recieverId, msg);
                Future.delayed(Duration(milliseconds: 200), () {
                  scrollDown();
                });
              }
            },
            icon: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}