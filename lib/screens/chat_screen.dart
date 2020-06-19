import 'package:buddylang/utilities/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buddylang/models/bubble.dart';
import 'package:buddylang/models/chat.dart';
import 'package:buddylang/models/message.dart';
import 'package:buddylang/models/user.dart';
import 'package:buddylang/services/database.dart';

class ChatInstance extends StatefulWidget {
  @override
  _ChatInstanceState createState() => _ChatInstanceState();
}

class _ChatInstanceState extends State<ChatInstance> {
  final DatabaseService database = DatabaseService();
  final TextEditingController _textController = TextEditingController();
  Chat chat;
  ScrollController controller = new ScrollController(initialScrollOffset: 45.0);
  User receiver;

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;

    // TO DO: Load User and update lastTimeOpen

    return StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService().getStream(args['chatId']),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          else {
            chat = Chat.fromSnapshot(snapshot.data);
            return StreamBuilder(
              stream: DatabaseService().getUserStream(
                  chat.users[0] != User.uid ? chat.users[0] : chat.users[1]),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                else {
                  receiver = User.fromSnapshot(snapshot.data);
                  return Scaffold(
                      appBar: AppBar(
                          title: Text(receiver.name,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false),
                          centerTitle: true,
                          backgroundColor: Colors.lightBlue[600],
                          actions: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0.0, 3.0, 3.0, 3.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.popAndPushNamed(context, '/homeScreen');
                                },
                                child: SizedBox(
                                  width: 50.0,
                                  height: 50.0,
                                  child: CachedNetworkImage(
                                    imageUrl: receiver.profileImageUrl == null
                                        ? defaultImage
                                        : receiver.profileImageUrl,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                            width: 30.0,
                                            height: 30.0,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover))),
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                            )
                          ]),
                      body: SafeArea(
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                child: ListView.builder(
                                    controller: controller,
                                    itemCount: chat.messages.length,
                                    itemBuilder:
                                        (BuildContext ctxt, int index) {
                                      DateTime previousMessageDate =
                                          DateTime.now();
                                      if (index > 0)
                                        previousMessageDate =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                chat.messages[index - 1]
                                                    .timeStamp);

                                      DateTime messageDate =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              chat.messages[index].timeStamp);
                                      if (index == 0 ||
                                          messageDate.day !=
                                              previousMessageDate.day ||
                                          messageDate.month !=
                                              previousMessageDate.month ||
                                          messageDate.year !=
                                              previousMessageDate.year) {
                                        return Column(children: <Widget>[
                                          Bubble.dateBubble(messageDate),
                                          Bubble.fromMessage(
                                              chat, index, User.uid, true)
                                        ]);
                                      }

                                      return Bubble.fromMessage(
                                          chat, index, User.uid, false);
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 0.0, 10.0, 0.0),
                                child: Row(children: <Widget>[
                                  Flexible(
                                    child: TextField(
                                      controller: _textController,
                                      keyboardType: TextInputType.multiline,
                                      minLines: 1,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                          hintText: 'Type a message'),
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  RaisedButton(
                                    color: Colors.lightBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(18.0),
                                    ),
                                    onPressed: () {
                                      if (_textController.text != "") {
                                        chat.sendMessage(Message(
                                            User.uid, _textController.text,
                                            timeStamp: DateTime.now()
                                                .millisecondsSinceEpoch));
                                        _textController.clear();
                                      }
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    },
                                    child:
                                        Icon(Icons.send, color: Colors.white),
                                  )
                                ]),
                              )
                            ],
                          ),
                        ),
                      ));
                }
              },
            );
          }
        });
  }
}
