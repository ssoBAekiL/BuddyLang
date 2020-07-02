import 'dart:ui';
import 'package:buddylang/EditSettings.dart';
import 'package:buddylang/utilities/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:buddylang/models/user.dart';
import 'package:buddylang/services/database.dart';
import 'dart:io';

import '../Visualize_Profile_Background.dart';
import '../Visualize_Profile_Picture.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override

  //functions to read and write, at the end you will find ############################
  //###############################################################################

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localBio async {
    final path = await _localPath;
    return File('$path/bio.txt');
  }

  Future<File> _write(String text) async {
    final file = await _localBio;
    file.writeAsString(text);
    // Write the file.
    return file;
  }

  Future<String> _read() async {
    try {
      final file = await _localBio;
      String body = await file.readAsString();
      // Read the file.
      return body;
    } catch (e) {
      // If encountering an error, return 0.
      return "Can't read";
    }
  }

  //end functions ###############################################################################
  //###############################################################################
  var _profPicture ;
  var _backGroundPicture;


  Future changeProfilePicture() async {
    var newImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _profPicture = newImage;
    });
  }

    Future changeBackgroundPicture() async {
      var newImage2 = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _backGroundPicture=newImage2;
      });
  }

  var _screenWidth ;
  var _customScreenHeight;
  var _customLabelsHeight;
  var _customImagesize ;
  User user;
  //var bio = "";
  //bamboozle= _MyRead().then((value) => String);
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    _customImagesize= 100.0 ;
    _screenWidth = MediaQuery.of(context).size.width * 0.94;
    _customScreenHeight= MediaQuery.of(context).size.height * 0.94;
    _customLabelsHeight = MediaQuery.of(context).size.height * 0.25;
   return new Scaffold(
     appBar: _appBar(),
     backgroundColor: Colors.grey,
     body: Align(
       alignment: Alignment.center,
     child : SizedBox(
       width: _screenWidth,
       height: _customScreenHeight,
       child: StreamBuilder(
         stream : DatabaseService().getUserStream('0yMz5c6hmd6JPyZXPIdD'),
         builder : (context, snapshot) {
           if (!snapshot.hasData)
             return Scaffold(
               body: Center(child: CircularProgressIndicator()),
             );
           else {
             user = User.fromSnapshot(snapshot.data);
             _backGroundPicture=user.backgroundImageUrl;
             print(user.languages);
             return Stack(
               children: <Widget>[
                 new ListView(
                   children: <Widget>[
                     _buildprofile(),
                     _buildbio(),
                     _buildlanguages(),
                     _buildInterests(),
                     _editButton(),
                   ],
                 ),
               ],
             );
           }
         }
       ),
      ),
     ),
   );
  }
Widget _appBar () {
    return new AppBar(
      backgroundColor: Colors.lightBlue,
      title: Text(
        'BuddyLang',
        style : TextStyle(color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: 28),
      ),
    );
}

  Widget _buildprofile(){
    return new Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        child : Stack(
      children: <Widget>[
        GestureDetector(
            onTap: () {
              visualizeProfileBackground();
            },//() //{
        //      Navigator.push(context, MaterialPageRoute(builder: (_) {
       //         return DetailScreen(tag: _tag[0], url: _url[0]);
       //       }));
           child : SizedBox(
            width : _screenWidth,
            height: _customLabelsHeight,
            child : Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
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
                            borderRadius: BorderRadius.circular(10),
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
          ),
        ),
        Positioned (
           top : 120,
          left : 5,
          child :  new GestureDetector(
            onTap: () {
              visualizeProfilePicture();
            },
            child : new SizedBox(
              width: _customImagesize,
              height: _customImagesize,
              child : new Stack(
                alignment: Alignment.center,
                children : <Widget>[
                  Container(
                    width: _customImagesize-12,
                    height: _customImagesize-12,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                      color: Colors.white,
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
                ],
              ),
            ),
          ),
        ),
          ],
        ),
    );
  }

  //al posto di avatar10 scrivere user.reference.toString()

  Widget _buildbio(){
    return new Padding(
      padding: EdgeInsets.fromLTRB(0, 17, 0, 0),
      child : Column(
        children: <Widget>[
          Align(
            alignment: Alignment(0,0),
            child: Text( "Biography :",
              style: TextStyle(
                color: Colors.black,
                fontSize: 27.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: Alignment(0,0),
                child : Card(
                elevation: 3.0,
                child : SizedBox(
                  width: _screenWidth,
                  height: _customLabelsHeight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
                    child: Text(
                       user.bio,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildlanguages(){
    return new Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child : Column(
          children: <Widget>[
            Align(
              alignment: Alignment(0,0),
              child: Text( "Which languages do you know?",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 27.0,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding : EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: SizedBox(
                width: _screenWidth,
                height: _customLabelsHeight,
                child : Card(
                  elevation: 3.0,
                  child:
                      Align(
                        alignment: Alignment(0,0),
                        child : _MyWrap(),
                      ),
                ),
              ),
            ),
          ],
      ),
    );
  }

  RaisedButton _getRandomButton(int i, String language) {
    if (i & 1 == 0) {
      return new RaisedButton(
        onPressed: null,
        child: Text(language,
           style: TextStyle(
            color: Colors.white
            ),
          ),
        disabledColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
      );
    }
    else {
      return new RaisedButton(
        onPressed: null,
        child: Text(language,
          style: TextStyle(
              color: Colors.black
          ),
        ),
        disabledColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
                color : Colors.black,
              width: 1.5,
            ),
        ),
      );
    }
  }

  Widget _MyWrap(){
    List<String> lang= user.languages;
    int len=lang.length;
    var list_lang= new List<RaisedButton>();
    for (var i=0; i<len; i++) {
      list_lang.add(
          _getRandomButton(i,lang[i])
      );
    }
    return Wrap(
      spacing: 22,
      children: list_lang,
    );
  }

  Widget _buildInterests(){
    return new Padding(
      padding: EdgeInsets.fromLTRB(0, 17, 0, 0),
      child : Column(
        children: <Widget>[
          Align(
            alignment: Alignment(0,0),
            child: Text( "Interests :",
              style: TextStyle(
                color: Colors.black,
                fontSize: 27.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: Alignment(0,0),
            child : Card(
              elevation: 3.0,
              child : SizedBox(
                width: _screenWidth,
                height: _customLabelsHeight,
                child: InterestsWrap(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ChipCreator(String text, int i){
    if  (i & 1 ==0 ) {
      return Chip(
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(
            color : Colors.black,
            width: 1.5,
          ),
        ),
        label: Text(
          text,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      );
    }
    else if  (i & 1 ==1 ) {
      return Chip(
        backgroundColor: Colors.black,
        label: Text(
          text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }
  }

  Widget ChipWrap(){
    List<String> user_interests= user.interests;
    var chip_list= List<Widget>();
    var len=user_interests.length;
    for(var i=0; i<len;i++){
      if(user_interests[i]==null){}
      else chip_list.add(ChipCreator(user_interests[i],i));
    }
    return Wrap(
      spacing: 22,
      runSpacing: 7,
      children: chip_list,
    );
  }

  Widget InterestsWrap(){
    return Align(
      alignment: Alignment(0,0),
      child : ChipWrap(),
    );
  }

  Widget _editButton(){
    return Align(
      alignment: Alignment.center,
      child : new RaisedButton(
          onPressed: navigate,
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.white),
        ),
        child : Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
      )
    );
  }

  void visualizeProfilePicture() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VisualizeProfilePicture(),
      ),
    );
  }

  void visualizeProfileBackground() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VisualizeProfileBackground(),
      ),
    );
  }

  void navigate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfile(),
      ),
    );
  }
}