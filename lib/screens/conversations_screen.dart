import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:buddylang/models/user.dart';
import 'package:buddylang/models/chat.dart';
import 'package:buddylang/models/message_entry.dart';
import 'package:buddylang/services/database.dart';
import 'package:timer_builder/timer_builder.dart';

class ConversationsScreen extends StatefulWidget {
  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final String defaultImage = 'https://firebasestorage.googleapis.com/v0/b/fir-buddylang.appspot.com/o/userImages%2Fuser_default.png?alt=media&token=209e897d-ab1e-41c6-9ebb-d90c94a6581d';
  User user;

  List<Chat> conversations = [];

  String receiver;

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(
      Duration(seconds: 1), //updates every second
      builder: (context) {
          return StreamBuilder(
          stream: DatabaseService().getUserStream(User.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            else {
              user = User.fromSnapshot(snapshot.data);
              return Scaffold(
              appBar: AppBar(title: Text('BuddyLang'), centerTitle: true),
              backgroundColor: Colors.grey[200],
              body: FutureBuilder<List<String>>(
                future: user.sortChat(),
                builder: (BuildContext context, AsyncSnapshot<List<String>> listSnapshot) {
                  if (!listSnapshot.hasData) {
                    // while data is loading:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    List<String> sortedChats = listSnapshot.data;
                  return ListView.builder(
                  itemCount: sortedChats.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return StreamBuilder(
                      stream: DatabaseService().getStream(sortedChats[index]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(child: CircularProgressIndicator());
                        else {
                          user.sortChat();
                          Chat chat = Chat.fromSnapshot(snapshot.data);
                          String receiver;
                          chat.users[0] == user.reference.documentID
                            ? receiver = chat.users[1]
                            : receiver = chat.users[0];
                          int lastMessageDate;
                          String lastMessage;
                          if (chat.messages.length > 0) {
                            lastMessage = chat
                              .messages[chat.messages.length - 1].message;
                            lastMessageDate = chat
                              .messages[chat.messages.length - 1].timeStamp;
                          }
                          else
                            lastMessage = 'New conversation!';
                          return MessageEntry(receiver, defaultImage, lastMessage,
                            lastMessageDate, chat.reference.documentID);
                        }
                      }
                    );
                  }
                );
                  
                  }
                }
              )
            );
            }
          });}
    );
  }
}