/*import 'package:buddylang/models/user_data.dart';
import 'package:buddylang/screens/home_screen.dart';
import 'package:buddylang/screens/login_screen.dart';
import 'package:buddylang/screens/user_test_screen.dart';
import 'package:buddylang/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';

void main() => runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => UserData()),
      Provider<AuthService>(
        create: (_) => AuthService(),
      ),
    ], child: MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuddyLang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: StreamBuilder<FirebaseUser>(
        stream: Provider.of<AuthService>(context, listen: false).user,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            User.uid = snapshot.data.uid;
            return snapshot.data.isEmailVerified
                ? HomeScreen()
                : LoginScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}*/


import 'package:buddylang/screens/home_screen.dart';
import 'package:buddylang/screens/login_screen.dart';
import 'package:buddylang/screens/user_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:buddylang/screens/chat_screen.dart';
import 'package:buddylang/screens/conversations_screen.dart';

void main() => runApp(MaterialApp(
  //initialRoute: '/conversationsScreen',
  //initialRoute: '/userTestScreen',
  initialRoute: '/preLogin',
  routes: {
    '/chatScreen': (context) => ChatInstance(), // Screen where the messages of a conversation are displayed
    '/conversationsScreen': (context) => ConversationsScreen(), // Screen where the list of conversations of the user are displayed
    '/userTestScreen': (context) => UserTestScreen(),
    '/loginScreen': (context) => LoginScreen(),
    '/homeScreen': (context) => HomeScreen(),
    '/preLogin': (context) => PreLogin()
  }
));