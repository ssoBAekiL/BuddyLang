import 'dart:io';
import 'package:buddylang/services/database.dart';
import 'package:buddylang/services/storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:buddylang/models/user.dart';
import 'package:image_picker/image_picker.dart';

class UserTestScreen extends StatefulWidget {
  @override
  _UserTestScreenState createState() => _UserTestScreenState();
}

class _UserTestScreenState extends State<UserTestScreen> {

  File imageFile;
  Image prova;

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      imageFile = selected;
    });
  }

 // 'https://miro.medium.com/max/1400/1*mk1-6aYaf_Bes1E3Imhc0A.jpeg'
// NetworkImage prova = NetworkImage('https://firebasestorage.googleapis.com/v0/b/fir-buddylang.appspot.com/o/userImages%2FprovaAvatar2?alt=media&token=afe5f423-13b2-4911-93c4-09f297c59652');
  final String defaultImage = 'https://firebasestorage.googleapis.com/v0/b/fir-buddylang.appspot.com/o/userImages%2Fuser_default.png?alt=media&token=209e897d-ab1e-41c6-9ebb-d90c94a6581d';
  User user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
          stream: DatabaseService().getUserStream('0yMz5c6hmd6JPyZXPIdD'),
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
            RaisedButton(onPressed: ()  {_pickImage(ImageSource.gallery);
              StorageService.uploadUserImage(imageFile, user.reference.toString()).then((url) => user.update(newProfileImageUrl: url));
            },
            child: Text('Select'))
          ],
        )
      ),
    );}
  });
  }
}