import 'package:buddylang/models/user.dart';
import 'package:buddylang/models/user_data.dart';
import 'package:buddylang/screens/conversations_screen.dart';
import 'package:buddylang/screens/home_screen.dart';
import 'package:buddylang/screens/login_screen.dart';
import 'package:buddylang/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserData()),
        Provider<AuthService>(create: (_) => AuthService())
      ],
      child: UserVerification(),
    );
  }
}

class UserVerification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: Provider.of<AuthService>(context, listen: false).user,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          User.uid = snapshot.data.uid;
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
