/******************************/
/*          BuddyLang         */
/*  Author: Pablo Borrelli    */
/******************************/

import 'package:flutter/material.dart';
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
  User user;
  List<Chat> conversations = [];
  User receiver;

  Widget _noChatsText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('You dont have any active chat',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26.0, color: Colors.grey[600])),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Click "Find buddy" below to begin a new conversation and start precticing a new language!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, color: Colors.grey[600])),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(Duration(seconds: 1), //updates every second
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
                  appBar: AppBar(
                    backgroundColor: Color(0xFF73AEF5),
                    title: Text(
                      'BuddyLang',
                      style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontSize: 28),
                    ),
                    centerTitle: true,
                  ),
                  backgroundColor: Colors.grey[200],
                  body: FutureBuilder<List<String>>(
                      future: user.sortChat(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<String>> listSnapshot) {
                        if (!listSnapshot.hasData) {
                          // while data is loading:
                          if (user.chats != null)
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          else
                            return _noChatsText();
                        } else if (user.chats == null ||
                            user.chats.length < 1) {
                          return _noChatsText();
                        } else {
                          List<String> sortedChats = listSnapshot.data;
                          return ListView.builder(
                              itemCount: sortedChats.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return StreamBuilder(
                                    stream: DatabaseService()
                                        .getStream(sortedChats[index]),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData)
                                        return Center(
                                            child: CircularProgressIndicator());
                                      else {
                                        user.sortChat();
                                        Chat chat =
                                            Chat.fromSnapshot(snapshot.data);
                                        int receiverInt;
                                        chat.users[0] ==
                                                user.reference.documentID
                                            ? receiverInt = 1
                                            : receiverInt = 0;
                                        /*chat.users[0] == user.reference.documentID
                                          ? receiver = chat.users[1]
                                          : receiver = chat.users[0];*/
                                        int lastMessageDate;
                                        String lastMessage;
                                        int unreadMessages = 0;
                                        if (chat.messages != null &&
                                            chat.messages.length > 0) {
                                          lastMessage = chat
                                              .messages[
                                                  chat.messages.length - 1]
                                              .message;
                                          lastMessageDate = chat
                                              .messages[
                                                  chat.messages.length - 1]
                                              .timeStamp;
                                          chat.messages.forEach((m) {
                                            if (m.timeStamp >
                                                chat.lastTimeRead[User.uid])
                                              unreadMessages++;
                                          });
                                        } else
                                          lastMessage = 'New conversation!';
                                        return StreamBuilder(
                                            stream: DatabaseService()
                                                .getUserStream(
                                                    chat.users[receiverInt]),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData)
                                                return Container(
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  child: Scaffold(
                                                    body: Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                  ),
                                                );
                                              else {
                                                receiver = User.fromSnapshot(
                                                    snapshot.data);
                                                return MessageEntry(
                                                    receiver,
                                                    lastMessage,
                                                    lastMessageDate,
                                                    chat.reference.documentID,
                                                    unreadMessages);
                                              }
                                            });
                                      }
                                    });
                              });
                        }
                      }));
            }
          });
    });
  }
}
