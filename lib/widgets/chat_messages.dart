import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/firebase_util.dart';
import 'message_bubble_widget.dart';

class ChatMessages extends StatefulWidget {
  final String otherUID;
  const ChatMessages({super.key, required this.otherUID});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  String docString = '';
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getChatDocumentId(FirebaseAuth.instance.currentUser!.uid, widget.otherUID);
  }

  void _getChatDocumentId(String currentUserUID, String otherUserUID) async {
    final currentUserData = await getCurrentUserData();
    bool _isClient = currentUserData['userType'] == 'CLIENT';
    final querySnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('supplierUID',
            isEqualTo: _isClient ? otherUserUID : currentUserUID)
        .where('clientUID',
            isEqualTo: _isClient ? currentUserUID : otherUserUID)
        .get();
    print('MATCHES: ${querySnapshot.docs.length}');

    if (querySnapshot.docs.isNotEmpty) {
      docString = querySnapshot.docs.first.id;
    } else {
      // Chat document doesn't exist yet, create a new one
      final newChatDocRef =
          FirebaseFirestore.instance.collection('messages').doc();
      await newChatDocRef.set({
        'supplierUID': _isClient ? otherUserUID : currentUserUID,
        'clientUID': _isClient ? currentUserUID : otherUserUID,
        'dateTimeCreated': DateTime.now(),
      });
      docString = newChatDocRef.id;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .doc(docString)
                .collection('messageThread')
                .orderBy('dateTimeSent', descending: true)
                .snapshots(),
            builder: (ctx, chatSnapshots) {
              if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
                return const Center(child: Text('No messages found'));
              }
              if (chatSnapshots.hasError) {
                return const Center(child: Text('Something went wrong...'));
              }

              final loadedMessages = chatSnapshots.data!.docs;
              return ListView.builder(
                  padding:
                      const EdgeInsets.only(bottom: 40, left: 13, right: 13),
                  reverse: true,
                  itemCount: loadedMessages.length,
                  itemBuilder: (ctx, index) {
                    final chatMessage = loadedMessages[index].data();
                    final nextChatMessage = index + 1 < loadedMessages.length
                        ? loadedMessages[index + 1].data()
                        : null;
                    final currentMessageUserID = chatMessage['sender'];
                    final nextMessageUserID = nextChatMessage != null
                        ? nextChatMessage['sender']
                        : null;
                    final nextUserIsSame =
                        nextMessageUserID == currentMessageUserID;
                    if (nextUserIsSame) {
                      return MessageBubble.next(
                          message: chatMessage['messageContent'],
                          isMe: FirebaseAuth.instance.currentUser!.uid ==
                              currentMessageUserID);
                    } else {
                      return MessageBubble.first(
                          message: chatMessage['messageContent'],
                          isMe: FirebaseAuth.instance.currentUser!.uid ==
                              currentMessageUserID);
                    }
                  });
            });
  }
}
