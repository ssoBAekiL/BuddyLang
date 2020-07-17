import 'package:buddylang/models/Visualize_Profile_Picture.dart';
import 'package:buddylang/models/visualizeProfileBackground.dart';
import 'package:buddylang/screens/editProfile_screen.dart';
import 'package:buddylang/screens/login_screen.dart';
import 'package:buddylang/screens/navigation_screen.dart';
import 'package:buddylang/screens/new_buddy_screen.dart';
import 'package:buddylang/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:buddylang/screens/chat_screen.dart';
import 'package:buddylang/screens/conversations_screen.dart';
import 'package:buddylang/screens/initial_screen.dart';

void main() => runApp(MaterialApp(
  title: 'BuddyLang',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(primaryColor: Colors.white),
  //initialRoute: '/conversationsScreen',
  //initialRoute: '/userTestScreen',
  initialRoute: '/preLogin',
  routes: {
    '/chatScreen': (context) => ChatInstance(), // Screen where the messages of a conversation are displayed
    '/conversationsScreen': (context) => ConversationsScreen(), // Screen where the list of conversations of the user are displayed
    //'/userTestScreen': (context) => UserTestScreen(),
    '/loginScreen': (context) => LoginScreen(),
    '/preLogin': (context) => PreLogin(),
    '/newBuddyScreen': (context) => NewBuddyScreen(),
    '/profileScreen': (context) => ProfileScreen(),
    '/navigationScreen': (context) => NavigationScreen(),
    '/editProfileScreen': (context) => EditProfile(),
    '/visualizeProfilePictureScreen': (context) => VisualizeProfilePicture(),
    '/visualizeProfileBackgroundScreen': (context) => VisualizeProfileBackground()
  }
));