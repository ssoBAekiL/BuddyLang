/******************************/
/*          BuddyLang         */
/*  Author: Pablo Borrelli    */
/******************************/

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'user.dart';

class Message {
  final String author;
  final String message;
  int timeStamp;

  DocumentReference reference;

  Message(this.author, this.message, {this.timeStamp}) {
    if (this.timeStamp == null) {
      this.timeStamp = DateTime.now().millisecondsSinceEpoch;
    }
  }

  factory Message.fromJson(Map<dynamic, dynamic> json) =>
      _messageFromJson(json);

  Map<String, dynamic> toJson() => _messageToJson(this);

  @override
  String toString() {
    return '$author: $message (${DateTime.fromMillisecondsSinceEpoch(timeStamp)})\n';
  }
}

Message _messageFromJson(Map<dynamic, dynamic> json) {
  return Message(json['author'] as String, json['message'] as String,
      timeStamp: json['timeStamp'] as int);
}

Map<String, dynamic> _messageToJson(Message instance) => <String, dynamic>{
      'author': instance.author,
      'message': instance.message,
      'timeStamp': instance.timeStamp
    };
