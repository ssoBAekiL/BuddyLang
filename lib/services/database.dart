/******************************/
/*          BuddyLang         */
/*  Author: Pablo Borrelli    */
/*  Last updated: 29/05/2020  */
import 'package:buddylang/screens/home_screen.dart';
/******************************/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buddylang/models/user.dart';
import 'package:buddylang/models/chat.dart';


class DatabaseService {
  final CollectionReference chatsCollectionRefernece =
    Firestore.instance.collection('chats'); // Reference to the firebase firestore collection of chats
  final CollectionReference usersCollectionRefernece =
    Firestore.instance.collection('users');  // Reference to the firebase firestore collection of users

  /*  Function that uploads all the information of a new user */
  /*  to the database and returns its reference ID            */
  Future<DocumentReference> addUser(User user) {
    return usersCollectionRefernece.add(user.toJson());
  }

  /*  Function that uploads all the information of a new Chat */
  /*  to the database and returns its reference ID            */
  Future<DocumentReference> createChat(Chat chat) {
    return chatsCollectionRefernece.add(chat.toJson());
  }

  /*   Function that updates the data of a given user in the database */
  void updateUser(User user) {
    usersCollectionRefernece.document(user.reference.documentID).updateData(user.toJson());
  }

  /*  Stream of Snapshot of a specific Chat form the database */
  Stream<DocumentSnapshot> getStream(String chatId) {
    return chatsCollectionRefernece.document(chatId).snapshots();
  }

  /*  Stream of Snapshot of a specific User from the database */
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return usersCollectionRefernece.document(uid).snapshots();
  }

  /*  Function that gets a static snapshot of a specific Chat from the database */
  Future<DocumentSnapshot> getChat(String chatId) {
    return chatsCollectionRefernece.document(chatId).get();
  }

  /*  Function that uploads a new Message inside it's specific chat int the database  */
  void updateChat(Chat chat) async {
    await chatsCollectionRefernece.document(chat.reference.documentID).updateData(chat.toJson());
  }

  Future<QuerySnapshot> getNewBuddy(String language) {
    return usersCollectionRefernece.where('languages', arrayContains: language).getDocuments();
  }

  void addChatToUser(String uid, String chatId, String user) {
    usersCollectionRefernece.document(uid).updateData({
      "chats": FieldValue.arrayUnion([chatId]),
      'buddys': FieldValue.arrayUnion([user])
    });
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return usersCollectionRefernece.document(uid).get();
  }
}