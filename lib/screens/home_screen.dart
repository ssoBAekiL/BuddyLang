import 'package:buddylang/models/user.dart';
import 'package:buddylang/services/auth_service.dart';
import 'package:buddylang/services/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

final String defaultImage = 'https://firebasestorage.googleapis.com/v0/b/fir-buddylang.appspot.com/o/userImages%2Fuser_default.png?alt=media&token=209e897d-ab1e-41c6-9ebb-d90c94a6581d';
  User user;

class _HomeScreenState extends State<HomeScreen> {
  _buildDrawerOption(Icon icon, String title, Function onTap) {
    return ListTile(
      leading: icon,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
      onTap: onTap,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('BuddyLang'),
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            
            child: StreamBuilder(
          stream: DatabaseService().getUserStream(User.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            else {
              user = User.fromSnapshot(snapshot.data);
              return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 60.0),
            CachedNetworkImage(
              imageUrl: user.profileImageUrl == null ? defaultImage : user.profileImageUrl,
              imageBuilder: (context, imageProvider) => Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover
                  )
                )
              ),
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Text(user.toString()),
            GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
              
                child: Stack(children: <Widget>[
                 
                  _buildDrawerOption(Icon(Icons.directions_run), 'LogOut',
                      () => AuthService().signOut())
                ]))
          ],
        )
      ),
    );}
  })));
  }
}