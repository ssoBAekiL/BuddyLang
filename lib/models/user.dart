/******************************/
/*          BuddyLang         */
/*  Author: Pablo Borrelli    */
/*  Last updated: 29/05/2020  */
/******************************/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buddylang/services/database.dart';
import 'package:buddylang/models/chat.dart';

class User {
  static String uid;
  String token = '';
  String bio = '';
  String profileImageUrl = '';
  String backgroundImageUrl = '';
  String name = '';
  int birthDate; 
  String livingCountry = '';
  List<String> interests = [];
  List<String> languages = [];
  List<String> chats = [];


  DocumentReference reference; // Reference to the firebase snapshot

  /*  Constructor of the User object, only name parameter is mandatory      */
  /*  since when a new user registers a first insance of the user is saved  */
  /*  in the databes only with that information                             */
  User(this.name, {this.token, this.bio, this.chats, this.reference, this.birthDate, this.livingCountry, this.interests, this.languages, this.profileImageUrl, this.backgroundImageUrl}) {
    if (token == null)
      this.token = '';
    if (livingCountry == null)
      this.livingCountry = '';
    if (interests == null)
      this.interests = [];
    if (languages == null)
      this.languages = [];
    if (chats == null)
      this.chats = [];

  }

  /*  factory that buids a User object from the */
  /*  json data returned by Firestore           */
  factory User.fromJson(Map<dynamic, dynamic> json) => _userFromJson(json);
   
  /*  factory that buids a User object from a   */
  /*  Firestore snapshot's data                 */
  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    User newUser = User.fromJson(snapshot.data);
    newUser.reference = snapshot.reference;
    return newUser;
  }

  /*  Function that converts the instanced Chat object into a json  */
  /*  Map that can be uploaded to Firestore through a static method */
  Map<String, dynamic> toJson() => _userToJson(this);

  Future<List<String>> sortChat() async {
    List<Chat> sortedChats = [];

    for (int i = 0; i < this.chats.length; i++) {
      Chat chat =  Chat.fromSnapshot(await DatabaseService().getChat(this.chats[i]));
      sortedChats.add(chat);
    }
    sortedChats.sort((a, b) {
      if  (b.messages.length < 1)
        return 1;
      else if (a.messages.length < 1)
        return -1;
      else
      return b.messages[b.messages.length -1].timeStamp.compareTo(a.messages[a.messages.length -1].timeStamp);
    });
    return sortedChats.map((c) => c.reference.documentID).toList();
  }

  /*  For debug only */
  @override
  String toString() {
    return '$name:\nbirth date: $birthDate\nliving country: $livingCountry\ninterests: $interests\nlanguages: $languages\nchats: $chats';
  }
  
  /*  Function that works as a setter for every variable in the class but also  */
  /*  updates the information in the database                                   */
  void update({String newToken, String newProfileImageUrl, String newBackgroundImageUrl, String newBio, String newName, int newBirthDate, String newLivingCountry, List<String> newInterests, List<String> newLanguages, List<String> newChats, int newLastRead}) {
    if (newToken != null)
      this.token = newToken;
    if (newProfileImageUrl != null)
      this.profileImageUrl = newProfileImageUrl;
    if (newBackgroundImageUrl != null)
      this.backgroundImageUrl = newBackgroundImageUrl;
    if (newBio != null)
      this.bio = newBio;
    if (newName != null)
      this.name = newName;
    if (newBirthDate != null)
      this.birthDate = newBirthDate;
    if (newLivingCountry != null)
      this.livingCountry = newLivingCountry;
    if (newInterests != null)
      this.interests = newInterests;
    if (newLanguages != null)
      this.languages = newLanguages;
    if (newChats != null)
      this.chats = newChats;
    //  Saves changes on the firebase database
    DatabaseService().updateUser(this);
  }

  /*  Adds a single interest to the list and updates the database */
  void addInterest(String interest) {
    this.interests.add(interest);
    DatabaseService().updateUser(this);
  }

  /*  Adds a single language to the list and updates the database */
  void addLanguage(String language) {
    this.languages.add(language);
    DatabaseService().updateUser(this);
  }

  /*  Adds a single chat to the list and updates the database */
  void addChat(String chat) {
    this.chats.add(chat);
    DatabaseService().updateUser(this);
  }

  /*  Removes an interest given it's string name and updates the database */
  void removeInterest(String interest) {
    this.interests.remove(interest);
    DatabaseService().updateUser(this);
  }
  
  /*  Removes a language given it's string name and updates the database */
  void removeLanguage(String language) {
    this.languages.remove(language);
    DatabaseService().updateUser(this);
  }

  /*  Removes a chat given it's string name and updates the database */
  void removeChat(String chat) {
    this.chats.remove(chat);
    DatabaseService().updateUser(this);
  }

}

/*  Private method that instantiates a new User object      */
/*  containing the data in the json received from Firestore */
User _userFromJson(Map<dynamic, dynamic> json) {
  return User(
    json['name'] as String,
    token: json['token'] as String,
    bio: json['bio'] as String,
    birthDate: json['birthDate'] as int,
    livingCountry: json['livingCountry'] as String,
    interests: _convertInterests(json['interests'] as List),
    languages: _convertLanguages(json['languages'] as List),
    chats: _convertChats(json['chats'] as List),
    profileImageUrl: json['profileImageUrl'] as String,
    backgroundImageUrl: json['backgroundImageUrl'] as String
    );
}

/*  Private method thar instantiates String objects from json Map        */
/*  and creates a List containing the ID's of every chat the user is in */
List<String> _convertChats(List chatsMap) {
  // User might be new and no data avaliable
  if (chatsMap == null) {
    return null;
  }
  List<String> chats = List<String>();
  chatsMap.forEach((c) {chats.add(c);});

  return chats;
}

/*  Private method thar instantiates String objects from json Map  */
/*  and creates a List containing the user's interests            */
List<String> _convertInterests(List interestsMap) {
  // User might be new and no data avaliable
  if (interestsMap == null) {
    return null;
  }
  List<String> interests = List<String>();
  interestsMap.forEach((value) {
    interests.add(value);
  });
  return interests;
}

/*  Private method thar instantiates String objects from json Map    */
/*  and creates a List containing the languages spoken by the user  */
List<String> _convertLanguages(List languagesMap) {
  // User might be new and no data avaliable
  if (languagesMap == null) {
    return null;
  }
  List<String> languages = List<String>();
  languagesMap.forEach((value) {
    languages.add(value);
  });
  return languages;
}

/*  Private method that builds the Firestore json Map of a User object */
Map<String, dynamic> _userToJson(User instance) =>
  <String, dynamic> {
    'name': instance.name,
    'bio': instance.bio,
    'birthDate': instance.birthDate,
    'livingCountry': instance.livingCountry,
    'interests': instance.interests,
    'languages': instance.languages,
    'chats': instance.chats,
    'profileImageUrl': instance.profileImageUrl,
    'backgroundImageUrl': instance.backgroundImageUrl,
    'token': instance.token
  };
