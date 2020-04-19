import 'package:buddylang/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

//autenticazione
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging =
      FirebaseMessaging(); //per abilitare il nostro token

  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  Future<void> signup(String name, String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (authResult.user != null) {
        String token = await _messaging.getToken();

        usersRef.document(authResult.user.uid).setData({
          'name': name,
          'email': email,
          'token': token //unico per ogni device
        });
      }
    } on PlatformException catch (err) {
      throw (err); //segnale errore se non sono valide le credenziali
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _auth.signInWithEmailAndPassword(email: email, password: password);
    } on PlatformException catch (err) {
      throw (err);
    }
  }

 /* Future<void> logout() {
    Future.wait([
      _auth.signOut(),
    ]);
  }*/
}
