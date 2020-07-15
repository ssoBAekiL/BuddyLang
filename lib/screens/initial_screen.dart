import 'package:buddylang/models/user.dart';
import 'package:buddylang/models/user_data.dart';
import 'package:buddylang/screens/editProfile_screen.dart';
import 'package:buddylang/screens/login_screen.dart';
import 'package:buddylang/screens/navigation_screen.dart';
import 'package:buddylang/services/auth_service.dart';
import 'package:buddylang/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          return FutureBuilder<DocumentSnapshot>(
              future: DatabaseService().getUser(User.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Scaffold(
                    body: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: Image(
                              image: AssetImage('assets/logos/logo_nosfondo.png')),
                        )
                        //child: CircularProgressIndicator(),
                        ),
                  );
                } else {
                  User user = User.fromSnapshot(snapshot.data);
                  if (user.bio == null ||
                      user.interests == null ||
                      user.languages == null) //||
                    //user.birthDate == null ||
                    //user.livingCountry == null ||
                    //user.name == null)
                    return EditProfile();
                  else
                    return NavigationScreen();
                }
              });
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
