import 'package:buddylang/utilities/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
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
  ScrollController _controller = new ScrollController();
  User receiver;

  void _sendMessage() {
    if (_textController.text != "") {
      chat.messages = chat.messages.reversed.toList();
      chat.sendMessage(Message(User.uid, _textController.text,
          timeStamp: DateTime.now().millisecondsSinceEpoch));
      _textController.clear();
    }
    FocusScope.of(context).requestFocus(new FocusNode());
    _scrollToBottom();
  }

  void _scrollToBottom() => _controller.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
  
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
            chat.messages = chat.messages.reversed.toList();
            ///////////////////////////////////
            print(chat.messages[0].timeStamp);
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
                                  const EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 5.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.popAndPushNamed(
                                      context, '/homeScreen');
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
                          ]
                        ),
                      resizeToAvoidBottomInset: true,
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
                                    reverse: true,
                                    shrinkWrap: true,
                                    controller: _controller,
                                    itemCount: chat.messages.length,
                                    itemBuilder:
                                        (BuildContext ctxt, int index) {
                                      DateTime previousMessageDate =
                                          DateTime.now();
                                      if (index < chat.messages.length - 1)
                                        previousMessageDate =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                chat.messages[index + 1]
                                                    .timeStamp);
                                      DateTime messageDate =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              chat.messages[index].timeStamp);
                                      if (messageDate.day !=
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
                              Container(
                                color: Colors.grey[300],
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 6.0, 10.0, 6.0),
                                  child: Container(
                                    child: Row(children: <Widget>[
                                      Flexible(
                                        child: TextField(
                                          controller: _textController,
                                          keyboardType: TextInputType.multiline,
                                          textInputAction: TextInputAction.send,
                                          onSubmitted: (value) {
                                            _sendMessage();
                                          },
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          minLines: 1,
                                          maxLines: 5,
                                          decoration: InputDecoration(
                                            hintText: 'Send a message...',
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    10.0, 0.0, 6.0, 0.0),
                                            filled: true,
                                            fillColor: Colors.white,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0)),
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0)),
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
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
                                          _sendMessage();
                                        },
                                        child: Icon(Icons.send,
                                            color: Colors.white),
                                      )
                                    ]),
                                  ),
                                ),
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
