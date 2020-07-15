/******************************/
/*          BuddyLang         */
/*  Author: Pablo Borrelli    */
/******************************/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buddylang/services/database.dart';
import 'package:buddylang/models/message.dart';


class Chat {
  //List<User> users = []; // List of users in the chat (initially limited to 2)
  List<String> users = []; // For first tests will only use Strings
  List<Message> messages = []; // List of all the messages in the chat
  Map lastTimeRead = {};

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
  Chat(this.users, {this.messages, this.lastTimeRead});

  /*  Function used to send a new message */
  /*  Only operates locally               */
  void sendMessage(Message message) {
    messages.add(message);
    DatabaseService().updateChat(this); // Server call to actual sending of the message
  }

  void updateLastTimeRead(String uid, int timestamp) {
    this.lastTimeRead[uid] = timestamp;
    DatabaseService().updateChat(this);
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
    return 'Users: ${users[0]}, ${users[1]}\n'
        'Messages:\n $messages';
  }

  Future<String> saveNewChat() async {
    String id;
    messages = [];
    lastTimeRead = {};
    users.forEach((uid) => lastTimeRead[uid] = 0);
    await DatabaseService().createChat(this).then((chatId) {
      users.forEach((u) => DatabaseService().addChatToUser(u, chatId.documentID, users[0] == u ? users[1] : users[0]));
      id = chatId.documentID;
    });
  return id;
  }

}

/*  Private method that instantiates a new Chat object      */
/*  containing the data in the json received from Firestore */
Chat _chatFromJson(Map<String, dynamic> json) {
  return Chat(
    // Json contains only uid String,users need to be instantiated with Firestore data
    // json['users'].forEach((u) => User(u, 'prova')).toList() as List,
    _convertUsers(json['users'] as List),
    // Messages need to be converted from json map to Message object and organized in a list
    messages: _convertMessages(json['messages'] as List),
    lastTimeRead: json['lastTimeRead'] as Map
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
  // No need to store full User object (redundant), only uid stored as String
  //'users': instance.users.map((u) => u.uid).toList(),
  'users': instance.users,
  // List of messages needs to be converted to its own json Map
  'messages': _messageList(instance.messages),
  'lastTimeRead': instance.lastTimeRead
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