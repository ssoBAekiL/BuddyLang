import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';

class MessageEntry extends StatefulWidget {
  final String chatId;
  String receiver;
  String receiverImageUrl;
  String lastMessage;
  int lastMessageDate;

  MessageEntry(this.receiver, this.receiverImageUrl, this.lastMessage, this.lastMessageDate, this.chatId);

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
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CachedNetworkImage(
              imageUrl: widget.receiverImageUrl,
              imageBuilder: (context, imageProvider) => Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover
                  )
                )
              ),
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            ),
              SizedBox(width: 15.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.receiver,
                        overflow: TextOverflow.ellipsis,
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
                      return Column(
                        children: <Widget>[
                          Text(
                              lastTimeStamp(DateTime.fromMillisecondsSinceEpoch(
                                  widget.lastMessageDate)),
                              style: TextStyle(
                                  fontSize: 13.0, color: Colors.grey[700])),
                          SizedBox(height: 10.0),
                          Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  '34',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ))
                        ],
                      );
                    })
            ],
          ),
        ),
      ),
    );
  }
}

String lastTimeStamp(DateTime lastTimeStamp) {
  if (lastTimeStamp.difference(DateTime.now()).inDays == 0 &&
      lastTimeStamp.day == DateTime.now().day)
    return DateFormat('Hm').format(lastTimeStamp).toString();
  else if (lastTimeStamp.difference(DateTime.now()).inDays == 0 &&
      lastTimeStamp.day == DateTime.now().day - 1)
    return 'Yesterday';
  else
    return DateFormat('d/M/yy').format(lastTimeStamp).toString();
}
