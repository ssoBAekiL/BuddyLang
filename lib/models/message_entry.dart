/******************************/
/*          BuddyLang         */
/*  Author: Pablo Borrelli    */
/******************************/

import 'package:buddylang/models/user.dart';
import 'package:buddylang/utilities/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';

class MessageEntry extends StatefulWidget {
  final String chatId;
  User receiver;
  String receiverImageUrl;
  String lastMessage;
  int lastMessageDate;
  int unreadMessages;

  MessageEntry(
      this.receiver, this.lastMessage, this.lastMessageDate, this.chatId, this.unreadMessages);

  @override
  _MessageEntryState createState() => _MessageEntryState();
}

class _MessageEntryState extends State<MessageEntry> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/chatScreen',
            arguments: {'chatId': widget.chatId});
      },
      child: Card(
        margin: EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 60.0,
                height: 60.0,
                child: CachedNetworkImage(
                  imageUrl: widget.receiver.profileImageUrl == null
                      ? defaultImage
                      : widget.receiver.profileImageUrl,
                  imageBuilder: (context, imageProvider) => Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover))),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(width: 15.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.receiver.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(fontSize: 16.0, color: Colors.black)),
                    Text(widget.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              SizedBox(width: 10.0),
              widget.lastMessageDate == null
                  ? Text('')
                  : TimerBuilder.periodic(
                      Duration(seconds: 60), //updates every second
                      builder: (context) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          children: <Widget>[
                            SizedBox(width: 56.0),
                            Text(
                                _lastTimeStamp(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        widget.lastMessageDate)),
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.grey[700])),
                            SizedBox(height: 10.0),
                            widget.unreadMessages > 0 ?
                            Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    widget.unreadMessages <= 99 ? widget.unreadMessages.toString() : '99+',
                                    style: TextStyle(color: Colors.white, fontSize: 13.0),
                                  ),
                                )) : Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    widget.unreadMessages.toString(),
                                    style: TextStyle(color: Colors.white, fontSize: 13.0),
                                  ),
                                ))
                          ],
                        ),
                      );
                    })
            ],
          ),
        ),
      ),
    );
  }
}

String _lastTimeStamp(DateTime lastTimeStamp) {
  if (lastTimeStamp.difference(DateTime.now()).inDays == 0 &&
      lastTimeStamp.day == DateTime.now().day)
    return DateFormat('Hm').format(lastTimeStamp).toString();
  else if (lastTimeStamp.difference(DateTime.now()).inDays == 0 &&
      lastTimeStamp.day == DateTime.now().day - 1)
    return 'Yesterday';
  else
    return DateFormat('d/M/yy').format(lastTimeStamp).toString();
}
