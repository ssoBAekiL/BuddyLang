import 'package:buddylang/models/user.dart';
import 'package:buddylang/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Future<void> signup(String name, String email, String password);
  Future<void> login(String email, String password);
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();
  Future<void> googleSignUp();
  Future<void> signOut();
  Future<FirebaseUser> getCurrentUser();
  Future<String> getUid();
  Future<void> signUpWithFacebook();
  Future<void> resetPassword(String email);
}

class AuthService implements BaseAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseMessaging _messaging = FirebaseMessaging();

  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  Stream<FirebaseUser> get onAuthStateChanged {
    return _auth.onAuthStateChanged.where((user) => user.isEmailVerified);
  }

  @override
  Future<void> signup(String name, String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (authResult.user != null) {
        String token = await _messaging.getToken();
        usersRef.document(authResult.user.uid).setData(User(name, token: token).toJson());

        //isEmailVerified();

        //authService.isEmailVerified();

        if (!authResult.user.isEmailVerified) await sendEmailVerification();
        return signOut();
      }
      //  await signOut();

    } on PlatformException catch (err) {
      throw (err);
    }
  }

  @override
  Future<String> getUid() async {
    FirebaseUser user = await _auth.currentUser();
    return user.uid.toString();
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on PlatformException catch (err) {
      throw (err);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  @override
  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _auth.currentUser();
    user.sendEmailVerification();
  }

  Future<void> logout() async {
    await removeToken();
    Future.wait([
      _auth.signOut(),
    ]);
  }

  Future<void> removeToken() async {
    final currentUser = await _auth.currentUser();
    await usersRef
        .document(currentUser.uid)
        .setData({'token': ''}, merge: true);
  }

  @override
  Future<void> googleSignUp() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      final FirebaseAuth _auth = FirebaseAuth.instance;

      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      print("signed in " + user.displayName);

      return user;
    } catch (e) {
      print(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> signUpWithFacebook() async {
    try {
      var facebookLogin = new FacebookLogin();
      var result = await facebookLogin.logIn(['email']);

      if (result.status == FacebookLoginStatus.loggedIn) {
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );
        final FirebaseUser user =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;

        print('signed in ' + user.displayName);

        return user;
      }
    } catch (e) {
      print(e.message);
    }
  }

  Future<void> updateToken() async {
    final currentUser = await _auth.currentUser();
    final token = await _messaging.getToken();
    final userSnapshot = await usersRef.document(currentUser.uid).get();
    if (userSnapshot.exists) {
      User user = User.fromSnapshot(userSnapshot);
      if (token != user.token) {
        usersRef
            .document(currentUser.uid)
            .setData({'token': token}, merge: true);
      }
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _auth.currentUser();
    return user.isEmailVerified;
  }
}
