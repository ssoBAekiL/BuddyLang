import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final Firestore _db = Firestore.instance;
final usersRef = _db.collection('users');
final chatsRef = _db.collection('chats');

final defaultImage = 'https://firebasestorage.googleapis.com/v0/b/fir-buddylang.appspot.com/o/userImages%2Fuser_default.png?alt=media&token=209e897d-ab1e-41c6-9ebb-d90c94a6581d';
final defaultBackgroundImage = 'https://firebasestorage.googleapis.com/v0/b/fir-buddylang.appspot.com/o/userBackgroungImages%2Fbackground_default.png?alt=media&token=5b96c00f-c513-4cd6-8f95-a17ebb232e61';

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);