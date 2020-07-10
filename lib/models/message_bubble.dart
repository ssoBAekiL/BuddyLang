import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:buddylang/models/message.dart';

class MessageWidget extends StatelessWidget {
  final Message message;

  MessageWidget(this.message);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(message.message,
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: 16)),
        SizedBox(height: 2.0),
        Text(
          DateFormat('Hm')
              .format(DateTime.fromMillisecondsSinceEpoch(message.timeStamp))
              .toString(),
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 10.0, color: Colors.grey[700]),
        )
      ],
    );
  }
}

