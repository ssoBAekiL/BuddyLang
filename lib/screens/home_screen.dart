import 'dart:io';
import 'package:buddylang/models/user.dart';
import 'package:buddylang/services/auth_service.dart';
import 'package:buddylang/services/database.dart';
import 'package:buddylang/services/storage.dart';
import 'package:buddylang/utilities/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

User user;

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _showChoiceDialog(BuildContext context, bool profileImage) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choose source'),
            content: SingleChildScrollView(
                child: ListBody(
              children: <Widget>[
                GestureDetector(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.insert_photo, color: Colors.grey),
                        SizedBox(width: 8.0),
                        Text('Gallery'),
                      ],
                    ),
                    onTap: () {
                      if (profileImage)
                        _pickImage(ImageSource.gallery, context, (File f) {
                          StorageService.uploadUserImage(
                              f, user.reference.documentID, user);
                        });
                      else
                        _pickImage(ImageSource.gallery, context, (File f) {
                          StorageService.uploadUserBackgroundImage(
                              f, user.reference.documentID, user);
                        });
                    }),
                SizedBox(width: 6.0),
                Divider(),
                SizedBox(width: 6.0),
                GestureDetector(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.photo_camera, color: Colors.grey),
                        SizedBox(width: 8.0),
                        Text('Camera'),
                      ],
                    ),
                    onTap: () {
                      if (profileImage)
                        _pickImage(ImageSource.camera, context, (File f) {
                          StorageService.uploadUserImage(
                              f, user.reference.documentID, user);
                        });
                      else
                        _pickImage(ImageSource.camera, context, (File f) {
                          StorageService.uploadUserBackgroundImage(
                              f, user.reference.documentID, user);
                        });
                    })
              ],
            )),
          );
        });
  }

  Future<void> _pickImage(ImageSource source, BuildContext context,
      Function(File f) uploader) async {
    PickedFile selected = await ImagePicker().getImage(source: source);
    File image = File(selected.path);

    setState(() {
      uploader(image);
    });

    Navigator.of(context).pop();
  }

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
                          SizedBox(
                            width: 120.0,
                            height: 60.0,
                            child: CachedNetworkImage(
                              imageUrl: user.backgroundImageUrl == null
                                  ? defaultBackgroundImage
                                  : user.backgroundImageUrl,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                      width: 120.0,
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover))),
                              placeholder: (context, url) => SizedBox(
                                  width: 80.0,
                                  height: 80.0,
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                          SizedBox(
                            width: 80.0,
                            height: 80.0,
                            child: CachedNetworkImage(
                              imageUrl: user.profileImageUrl == null
                                  ? defaultImage
                                  : user.profileImageUrl,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                      width: 80.0,
                                      height: 80.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover))),
                              placeholder: (context, url) => SizedBox(
                                  width: 80.0,
                                  height: 80.0,
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                          Text(user.toString()),
                          RaisedButton(
                              onPressed: () {
                                _showChoiceDialog(context, true);
                              },
                              child: Text('Select profile picture')),
                          RaisedButton(
                              onPressed: () {
                                _showChoiceDialog(context, false);
                              },
                              child: Text('Select background image')),
                          RaisedButton(
                              onPressed: () {
                                AuthService().signOut();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login', (Route<dynamic> route) => false);
                              },
                              child: Text("Log Out!")),
                          GestureDetector(
                              onTap: () => FocusScope.of(context).unfocus(),
                              child: Stack(children: <Widget>[
                                _buildDrawerOption(Icon(Icons.directions_run),
                                    'LogOut', () => AuthService().signOut())
                              ]))
                        ],
                      )),
                    );
                  }
                })));
  }
}
