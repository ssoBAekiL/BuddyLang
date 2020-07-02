import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buddylang/services/database.dart';
import 'package:buddylang/models/user.dart';
import 'package:buddylang/models/message.dart';
import 'package:buddylang/services/storage.dart';

import 'message.dart';


class Chat {
  //List<User> users = []; // List of users in the chat (initially limited to 2)
  List<String> users = []; // For first tests will only use Strings
  List<Message> messages = []; // List of all the messages in the chat
  final String chatId;  // Unique identifier of the chat

  DocumentReference reference; // Reference to the firebase snapshot

  /*  Constructor for Chat object                */
  /*  Arguments:
        - chatId (String)
        - users (List<User>)
      Named optional arguments:
        -lastMessageDate: (int)
        -messages: (List<Message>)
      if lastMessageDate not given it will be set
      to current time since that only happens if
      the chat has just been created              */
  Chat(this.chatId, this.users, {this.messages}) {
    if (this.messages == null) {
      this.messages = [];
    }
  }

  /*  Function used to send a new message */
  /*  Only operates locally               */
  void sendMessage(Message message) {
    messages.add(message);
    DatabaseService().saveMessage(this); // Server call to actual sending of the message
  }

  /*  factory that buids a Chat object from a   */
  /*  Firestore snapshot's data                 */
  factory Chat.fromSnapshot(DocumentSnapshot snapshot) {
    Chat newChat = Chat.fromJson(snapshot.data);
    newChat.reference = snapshot.reference;
    return newChat;
  }

  /*  factory that buids a Chat object from the */
  /*  json data returned by Firestore           */
  factory Chat.fromJson(Map<String, dynamic> json) => _chatFromJson(json);

  /*  Function that converts the instanced Chat object into a json  */
  /*  Map that can be uploaded to Firestore through a static method */
  Map<String, dynamic> toJson() => _chatToJson(this);

  /*  For debug only */
  @override
  String toString() {
    return 'Chat ID: $chatId\nUsers: ${users[0]}, ${users[1]}\n'
        'Messages:\n $messages';
  }
}

/*  Private method that instantiates a new Chat object      */
/*  containing the data in the json received from Firestore */
Chat _chatFromJson(Map<String, dynamic> json) {
  return Chat(
    json['chatId'] as String,
    // Json contains only uid String,users need to be instantiated with Firestore data
    // json['users'].forEach((u) => User(u, 'prova')).toList() as List,
    _convertUsers(json['users'] as List),
    // Messages need to be converted from json map to Message object and organized in a list
    messages: _convertMessages(json['messages'] as List),
  );
}

/*  Private method thar instantiates Message objects from json Map */
/*  and creates the List object that will be contained in Chat    */
List<Message> _convertMessages(List messageMap) {
  // Conversation might be new and empty
  if (messageMap == null) {
    return null;
  }
  List<Message> messages = List<Message>();
  messageMap.forEach((value) {
    messages.add(Message.fromJson(value));
  });
  return messages;
}

/*  Private method that instantiates String objects from json Map */
/*  and creates the List object that will be contained in Chat    */
List<String> _convertUsers(List usersMap) {
  if (usersMap == null) {
    return null;
  }
  List<String> users = List<String>();
  usersMap.forEach((value) {
    users.add(value);
  });
  return users;
}


// Unused untill String user will be changed for User object
/*List<User> _convertUsers(List usersMap) {
  if (usersMap == null) {
    return null;
  }
  List<User> users = List<User>();
  usersMap.forEach((uid) {
    users.add(User(uid, 'TestBuilder')); // needs to be changed to factory from firestore
  });
  return users;
}*/

/*  Private method that builds the Firestore json Map of a Chat object */
Map<String, dynamic> _chatToJson(Chat instance) => <String, dynamic> {
  'chatId': instance.chatId,
  // No need to store full User object (redundant), only uid stored as String
  //'users': instance.users.map((u) => u.uid).toList(),
  'users': instance.users,
  // List of messages needs to be converted to its own json Map
  'messages': _messageList(instance.messages)
};

/*  Private method that builds the Firestore json Map of a List<Message> */
List<Map<String, dynamic>> _messageList(List<Message> messages) {
  // Conversation might be new and empty
  if (messages == null) {
    return null;
  }
  List<Map<String, dynamic>> messageMap = List<Map<String, dynamic>>();
  messages.forEach((message) {
    messageMap.add(message.toJson());
  });
  return messageMap;
}