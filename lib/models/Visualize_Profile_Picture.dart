import 'package:buddylang/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:buddylang/services/database.dart';
import 'package:buddylang/models/user.dart';

class VisualizeProfilePicture extends StatefulWidget {
  @override
  VisualizeProfilePictureState createState() => VisualizeProfilePictureState();
}

class VisualizeProfilePictureState extends State<VisualizeProfilePicture> {
  User user;
  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    if (args == null) {
      args = {};
      args['uid'] = User.uid;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF73AEF5),
        title: Text('Profile Picture'),
      ),
      body: StreamBuilder(
          stream: DatabaseService().getUserStream(args['uid']),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            else {
              user = User.fromSnapshot(snapshot.data);
              return Center(
                child: Hero(
                  tag: 'imageHero',
                  child: CachedNetworkImage(
                    imageUrl: user.profileImageUrl == null
                            ? defaultImage
                            : user.profileImageUrl,
                    placeholder: (context, imageUrl) =>
                        CircularProgressIndicator(),
                    errorWidget: (context, imageUrl, error) =>
                        Icon(Icons.error),
                  ),
                ),
              );
            }
          }),
    );
  }
}

class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: CachedNetworkImage(
              imageUrl:
                  'https://raw.githubusercontent.com/flutter/website/master/src/_includes/code/layout/lakes/images/lake.jpg',
              placeholder: (context, imageUrl) => CircularProgressIndicator(),
              errorWidget: (context, imageUrl, error) => Icon(Icons.error),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
