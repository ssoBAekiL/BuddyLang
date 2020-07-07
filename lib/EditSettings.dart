import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:buddylang/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:buddylang/services/database.dart';
import 'package:buddylang/services/storage.dart';
import 'package:buddylang/utilities/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfile extends StatefulWidget{
  @override
  EditProfileState createState() => EditProfileState();
// TODO: implement createState
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File>  _localFile(String name) async {
  final path = await _localPath;
  print(path);
  return File('$path/$name');
}

Future<File> _write(String text, String filename) async {
  final file = await _localFile(filename);

  // Write the file.
  return file.writeAsString(text);
}

Future<String> _read(String filename) async {
  try {
    final file = await _localFile(filename);

    // Read the file.
    return await file.readAsString();
  } catch (e) {
    // If encountering an error, return 0.
    return "Can't read";
  }
}

String _myRead( String filename){
  var _fileContent;

  _read(filename).then((String) {
    _fileContent = String;
  });
  return _fileContent;
}


class EditProfileState extends State<EditProfile> {
  @override
  File _profPicture;
  File _backGroundPicture;
  var bio_ = TextEditingController();
  var name_ = TextEditingController();
  var birthDate_ = TextEditingController();
  var _newCountry ;
  var _newBirthDate =DateTime.now();


  Future changeProfilePicture() async {
    final picker = ImagePicker();
    final newImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _profPicture = File(newImage.path);
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _newBirthDate,
        firstDate: DateTime(1960, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != _newBirthDate)
      setState(() {
        user.update(newBirthDate: picked.microsecondsSinceEpoch);
      });
  }


  Future changeBackgroundPicture() async {
    final picker = ImagePicker();
    final newImage2 = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _backGroundPicture = File(newImage2.path);
    });
  }
  var _screenWidth;
  var _customScreenHeight;
  var _customLabelsHeight;
  var _customImagesize ;

  List<String> futureButtons;
  User user;
  List<String> lang_list= List<String>(11);
  var bool_list=List<bool>(11);
  List<String> interests=List<String>(6);
  var bool_interest=List<bool>(6);
  var studied=List<String>();
  var interested=List<String>();
  void initState() {
    _customImagesize= 100.0 ;
    interests[0]="Sport";
    interests[1]="Videogames";
    interests[2]="Food";
    interests[3]="TV Series";
    interests[4]="Dance";
    interests[5]="Culture";
    //########################//
    lang_list[0]="Arabian";
    lang_list[1]="Chinese";
    lang_list[2]="English";
    lang_list[3]="French" ;
    lang_list[4]="German";
    lang_list[5]="Indian";
    lang_list[6]="Italian";
    lang_list[7]="Japanese";
    lang_list[8]="Portughese";
    lang_list[9]="Russian";
    lang_list[10]="Spanish";
    for (var i=0; i<=10;i++)
      bool_list[i]=false; // 0 false, 1 true
    for (var i=0; i<=5;i++)
      bool_interest[i]=false; // 0 false, 1 true
    super.initState();
  }


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

  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width * 0.94;
    _customScreenHeight= MediaQuery.of(context).size.height * 0.94;
    _customLabelsHeight = MediaQuery.of(context).size.height * 0.25;
    var attempt ;
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
                  bio_.text=user.bio;
                 studied= user.languages;
                 interested=user.interests;
                 attempt =  DateTime.fromMicrosecondsSinceEpoch(user.birthDate);
                 print(attempt);
                  //newBirthDate = DateTime.fromMillisecondsSinceEpoch(user.birthDate);
                  return GestureDetector(
                    onTap:  (){
                     FocusScope.of(context).unfocus();
                    },
                    child: Stack(
                    children: <Widget>[
                      new ListView(
                      children: <Widget>[
                        _Edit_Info(),
                        Text(
                          "Tap below to edit background or profile picture ",
                          style: TextStyle(
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildprofile(),
                        _buildbio(),
                        _buildlanguages(),
                       _buildInterests(),
                        _saveButton(),
                       ],
                      ),
                    ],
                    ),
                  );
                }
              }
          ),
        ),
      ),
    );
  }

  Widget _change_name() {
    return Wrap(
      children: <Widget>[
        Text(
          "  Name : ",
          style: TextStyle(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          child : TextFormField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Insert new name",
            ),
            controller: name_,
            keyboardType: TextInputType.text,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ],
    );
  }


    Widget _change_country(){
      Widget _edit_country(){
        return DropdownButton<String>(
          items: [
            DropdownMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Icon(Icons.filter_1),
                  Text('Middle East'),
                ],
              ),
              value: 'Middle East',
            ),
            DropdownMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Icon(Icons.filter_2),
                  Text('China'),
                ],
              ),
              value: 'China',
            ),
            DropdownMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Icon(Icons.filter_3),
                  Text('England'),
                ],
              ),
              value: 'England',
            ),
            DropdownMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Icon(Icons.filter_4),
                  Text('France'),
                ],
              ),
              value: 'France',
            ),
            DropdownMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Icon(Icons.filter_5),
                  Text('India'),
                ],
              ),
              value: 'India',
            ),
            DropdownMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Icon(Icons.filter_6),
                  Text('Italy'),
                ],
              ),
              value: 'Italy',
            ),
            DropdownMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Icon(Icons.filter_7),
                  Text('Japan'),
                ],
              ),
              value: 'Japan',
            ),
            DropdownMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Icon(Icons.filter_8),
                  Text('Germany'),
                ],
              ),
              value: 'Germany',
            ),
            DropdownMenuItem<String>(
              child: Row(
                children: <Widget>[
                  Icon(Icons.filter_9),
                  Text('Other'),
                ],
              ),
              value: 'Other',
            ),
          ],
          isExpanded: false,
          onChanged: (String value) {
            setState(() {
              _newCountry = value;
            });
          },
          hint: Text('Select Country'),
          value: _newCountry,
          underline: Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))
            ),
          ),
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
          ),
          iconEnabledColor: Colors.pink,
          //        iconDisabledColor: Colors.grey,
          iconSize: 30,
        );
      }
      return Wrap(
        children: <Widget>[
          Text(
            "  Living Country : ",
            style: TextStyle(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
            child : _edit_country(),
          ),
        ],
      );
  }

  Widget _change_birth() {
    return Wrap(
      spacing: 50,
      runSpacing: 10,
      children: <Widget>[
        Text(
          "  Actual birth date :",
          style: TextStyle(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold
          ),
        ),
        Align(
          alignment: Alignment(-0.5,0),
          child: Text("${DateTime.fromMicrosecondsSinceEpoch(user.birthDate).toLocal()}".split(' ')[0],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 24,
            ),
          ),
        ),
        Align(
          alignment: Alignment(0,0),
          child : RaisedButton(
            color: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.black),
            ),
          onPressed: () => _selectDate(context),
          child: Text(
              'Select date',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),),
         ),
        ),
      ],
    );
  }


  //void update_user_Birth(){
 //   user.update(newBirthDate: (DateTime.now().year)-((DateTime.utc(birthDate_)).year));
  //  FocusScope.of(context).unfocus();
  //}
  void update_user_country(){
    user.update(newLivingCountry: _newCountry);
  }

  void update_user_name(){
    if ( name_.text == "" || name_.text == " " ) print("name is empty");
    else { print(name_.value); user.update(newName: name_.text);};
  }

  void update_all() {
    update_user_name();
    update_user_country();
    FocusScope.of(context).unfocus();
    Fluttertoast.showToast(
      msg: "Done",
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.lightBlue,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  Widget _SaveUpdates(){
    return Align(
        alignment: Alignment.center,
        child : new RaisedButton(
            onPressed: update_all,
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.white),
            ),
            child : Text(
              "Update",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
        )
    );
  }

  Widget _Edit_Info(){
    return Card(
      elevation: 3.0,
        child: SizedBox(
        width: _screenWidth,
        height: _customLabelsHeight*1.6,
        child : ListView(
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _change_name(),
              _change_country(),
              _change_birth(),
              _SaveUpdates(),
            ],
          ),
        ],
        ),
        ),
    );
  }

  Widget _appBar () {
    return new AppBar(
      leading:IconButton(
        onPressed: goBack,
        icon : Icon(Icons.arrow_back_ios),
        color: Colors.white,
      ),
      backgroundColor: Colors.lightBlue,
      title: Text(
        'BuddyLang',
        style : TextStyle(color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: 28),
      ),
    );
  }

  void goBack(){
    user.update(newLanguages: studied);
    Navigator.pop(context);
  }

  Widget _buildprofile() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: Container(
          width: _screenWidth,
          height: _customLabelsHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child : Stack(
            children: <Widget>[
              GestureDetector(
                onTap: ()=> _showChoiceDialog(context,false),
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
                                      fit: BoxFit.cover
                                  ),
                              ),
                          ),
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
              new Positioned(
                top: 100,
                left: 5,
                child : GestureDetector(
                  onTap: () => _showChoiceDialog(context, true),
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
        ),
      );
  }

  void func(){
    user.update(newBio: bio_.text);
    FocusScope.of(context).unfocus();
  }

  Widget _buildbio() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0, 17, 0, 0),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment(0, 0),
            child: Text("Biography :",
              style: TextStyle(
                color: Colors.black,
                fontSize: 27.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
              elevation: 3.0,
              child: SizedBox(
                width: _screenWidth,
                height: _customLabelsHeight,
                child : Stack(
                  children: <Widget>[
                    Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: SizedBox(
                      width: _screenWidth*0.8,
                      height: _customLabelsHeight,
                      child : TextField(
                        decoration: InputDecoration(
                          border:InputBorder.none,
                        ),
                        controller: bio_,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                     ),
                    ),
                    Align(
                      alignment: Alignment(0.96,0.0),
                        child : Container(
                            width: 40,
                            height: 40,
                            child : FloatingActionButton(
                              onPressed: func,
                              child: Icon(
                                Icons.send,
                                size: 20.0,
                              ),
                            )
                        ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildlanguages() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment(0, 0),
            child: Text("Which languages do you know?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 27.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: SizedBox(
              width: _screenWidth,
              height: MediaQuery.of(context).size.height*0.23,
              child: Card(
                elevation: 3.0,
                child: Align(
                alignment: Alignment(0,0),
                  child: myCheckBoxes(),
                ), //CheckContainer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget MyWrap(){
    return Wrap (
      spacing: 30,
     runSpacing: 7,
     alignment: WrapAlignment.spaceAround,
     children: <Widget>[
      // number 0 : Arabian
      Container(
      width: 125,
      height: 20,
      child: Row(
        children: <Widget>[
          Checkbox(
            value : bool_list[0],
            onChanged: (bool newVal){
              setState(() {
                bool_list[0]=newVal;
                if(newVal==true) {
                  studied.add(lang_list[0]);
                  user.update(newLanguages: studied);
                }
                else if (newVal==false) {
                  studied.remove(lang_list[0]);
                  user.update(newLanguages: studied);
                }
              });
            },
          ),
          Text(lang_list[0]),
        ],
      ),
    ),
       //number 1
       Container(
         width: 125,
         height: 20,
         child: Row(
           children: <Widget>[
             Checkbox(
               value : bool_list[1],
               onChanged: (bool newVal){
                 setState(() {
                   bool_list[1]=newVal;
                   if(newVal==true) {
                     studied.add(lang_list[1]);
                     user.update(newLanguages: studied);
                   }
                   else if (newVal==false) {
                     studied.remove(lang_list[1]);
                     user.update(newLanguages: studied);
                   }
                 });
               },
             ),
             Text(lang_list[1]),
           ],
         ),
       ),
       //number 2
       Container(
         width: 125,
         height: 20,
         child: Row(
           children: <Widget>[
             Checkbox(
               value : bool_list[2],
               onChanged: (bool newVal){
                 setState(() {
                   bool_list[2]=newVal;
                   if(newVal==true) {
                     studied.add(lang_list[2]);
                     user.update(newLanguages: studied);
                   }
                   else if (newVal==false) {
                     studied.remove(lang_list[2]);
                     user.update(newLanguages: studied);
                   }
                 });
               },
             ),
             Text(lang_list[2]),
           ],
         ),
       ),
       //number 3
       Container(
         width: 125,
         height: 20,
         child: Row(
           children: <Widget>[
             Checkbox(
               value : bool_list[3],
               onChanged: (bool newVal){
                 setState(() {
                   bool_list[3]=newVal;
                   if(newVal==true) {
                     studied.add(lang_list[3]);
                     user.update(newLanguages: studied);
                   }
                   else if (newVal==false) {
                     studied.remove(lang_list[3]);
                     user.update(newLanguages: studied);
                   }
                 });
               },
             ),
             Text(lang_list[3]),
           ],
         ),
       ),
       //number 4
       Container(
         width: 125,
         height: 20,
         child: Row(
           children: <Widget>[
             Checkbox(
               value : bool_list[4],
               onChanged: (bool newVal){
                 setState(() {
                   bool_list[4]=newVal;
                   if(newVal==true) {
                     studied.add(lang_list[4]);
                     user.update(newLanguages: studied);
                   }
                   else if (newVal==false) {
                     studied.remove(lang_list[4]);
                     user.update(newLanguages: studied);
                   }
                 });
               },
             ),
             Text(lang_list[4]),
           ],
         ),
       ),
       //number 5
       Container(
         width: 125,
         height: 20,
         child: Row(
           children: <Widget>[
             Checkbox(
               value : bool_list[5],
               onChanged: (bool newVal){
                 setState(() {
                   bool_list[5]=newVal;
                   if(newVal==true) {
                     studied.add(lang_list[5]);
                     user.update(newLanguages: studied);
                   }
                   else if (newVal==false) {
                     studied.remove(lang_list[5]);
                     user.update(newLanguages: studied);
                   }
                 });
               },
             ),
             Text(lang_list[5]),
           ],
         ),
       ),
       //number 6
       Container(
         width: 125,
         height: 20,
         child: Row(
           children: <Widget>[
             Checkbox(
               value : bool_list[6],
               onChanged: (bool newVal){
                 setState(() {
                   bool_list[6]=newVal;
                   if(newVal==true) {
                     studied.add(lang_list[6]);
                     user.update(newLanguages: studied);
                   }
                   else if (newVal==false) {
                     studied.remove(lang_list[6]);
                     user.update(newLanguages: studied);
                   }
                 });
               },
             ),
             Text(lang_list[6]),
           ],
         ),
       ),
       //number 7
       Container(
         width: 125,
         height: 20,
         child: Row(
           children: <Widget>[
             Checkbox(
               value : bool_list[7],
               onChanged: (bool newVal){
                 setState(() {
                   if(newVal==true) {
                     studied.add(lang_list[7]);
                     user.update(newLanguages: studied);
                   }
                   else if (newVal==false) {
                     studied.remove(lang_list[7]);
                     user.update(newLanguages: studied);
                   }
                   bool_list[7]=newVal;
                 });
               },
             ),
             Text(lang_list[7]),
           ],
         ),
       ),
       //number 8
       Container(
         width: 135,
         height: 20,
         child: Row(
           children: <Widget>[
             Checkbox(
               value : bool_list[8],
               onChanged: (bool newVal){
                 setState(() {
                   bool_list[8]=newVal;
                   if(newVal==true) {
                     studied.add(lang_list[8]);
                     user.update(newLanguages: studied);
                   }
                   else if (newVal==false) {
                     studied.remove(lang_list[8]);
                     user.update(newLanguages: studied);
                   }
                 });
               },
             ),
             Text(lang_list[8]),
           ],
         ),
       ),
       //number 9
       Container(
         width: 125,
         height: 20,
         child: Row(
           children: <Widget>[
             Checkbox(
               value : bool_list[9],
               onChanged: (bool newVal){
                 setState(() {
                   bool_list[9]=newVal;
                   if(newVal==true) {
                     studied.add(lang_list[9]);
                     user.update(newLanguages: studied);
                   }
                   else if (newVal==false) {
                     studied.remove(lang_list[9]);
                     user.update(newLanguages: studied);
                   }
                 });
               },
             ),
             Text(lang_list[9]),
           ],
         ),
       ),
       //number 10
       Container(
         width: 125,
         height: 20,
         child: Row(
           children: <Widget>[
             Checkbox(
               value : bool_list[10],
               onChanged: (bool newVal){
                 setState(() {
                   bool_list[10]=newVal;
                   if(newVal==true) {
                     studied.add(lang_list[10]);
                     user.update(newLanguages: studied);
                   }
                   else if (newVal==false) {
                     studied.remove(lang_list[10]);
                     user.update(newLanguages: studied);
                   }
                 });
               },
             ),
             Text(lang_list[10]),
           ],
         ),
       ),
     ],
    );
  }

 Widget myCheckBoxes(){
    int stud_len=studied.length;
    for (var i=0;i<stud_len;i++){
      for (var j=0;j<=10;j++){
        if(lang_list[j]==studied[i]){
            bool_list[j]=true;
          }
        }
      }
    return MyWrap();
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
                child: Align(
                  alignment : Alignment(0,0),
                  child : myInterestsCheckBoxes(),
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }

  Widget myInterestsCheckBoxes(){
    int interested_len=interested.length;
    for (var i=0;i<interested_len;i++){
      for (var j=0;j<=5;j++){ //6 interests
        if(interests[j]==interested[i]){
          bool_interest[j]=true;
        }
      }
    }
    return interests_Wrap();
  }

  Widget interests_Wrap(){
    return Wrap (
      spacing: 22,
      runSpacing: 15,
      alignment: WrapAlignment.spaceAround,
      children: <Widget>[
      // number 0 : Sport
      Container(
      width: 135,
      height: 20,
      child: Row(
        children: <Widget>[
          Checkbox(
            value : bool_interest[0],
            onChanged: (bool newVal){
              setState(() {
                bool_interest[0]=newVal;
                if(newVal==true) {
                  interested.add(interests[0]);
                  user.update(newInterests: interested);
                }
                else if (newVal==false) {
                  interested.remove(interests[0]);
                  user.update(newInterests: interested);
                }
              });
            },
          ),
          Text(interests[0]),
        ],
      ),
    ),
    //number 1
        Container(
          width: 140,
          height: 20,
          child: Row(
            children: <Widget>[
              Checkbox(
                value : bool_interest[1],
                onChanged: (bool newVal){
                  setState(() {
                    bool_interest[1]=newVal;
                    if(newVal==true) {
                      interested.add(interests[1]);
                      user.update(newInterests: interested);
                    }
                    else if (newVal==false) {
                      interested.remove(interests[1]);
                      user.update(newInterests: interested);
                    }
                  });
                },
              ),
              Text(interests[1]),
            ],
          ),
        ),
        //number 2
        Container(
          width: 125,
          height: 20,
          child: Row(
            children: <Widget>[
              Checkbox(
                value : bool_interest[2],
                onChanged: (bool newVal){
                  setState(() {
                    bool_interest[2]=newVal;
                    if(newVal==true) {
                      interested.add(interests[2]);
                      user.update(newInterests: interested);
                    }
                    else if (newVal==false) {
                      interested.remove(interests[2]);
                      user.update(newInterests: interested);
                    }
                  });
                },
              ),
              Text(interests[2]),
            ],
          ),
        ),
        //number 3
        Container(
          width: 125,
          height: 20,
          child: Row(
            children: <Widget>[
              Checkbox(
                value : bool_interest[3],
                onChanged: (bool newVal){
                  setState(() {
                    bool_interest[3]=newVal;
                    if(newVal==true) {
                      interested.add(interests[3]);
                      user.update(newInterests: interested);
                    }
                    else if (newVal==false) {
                      interested.remove(interests[3]);
                      user.update(newInterests: interested);
                    }
                  });
                },
              ),
              Text(interests[3]),
            ],
          ),
        ),
        //number 4
        Container(
          width: 125,
          height: 20,
          child: Row(
            children: <Widget>[
              Checkbox(
                value : bool_interest[4],
                onChanged: (bool newVal){
                  setState(() {
                    bool_interest[4]=newVal;
                    if(newVal==true) {
                      interested.add(interests[4]);
                      user.update(newInterests: interested);
                    }
                    else if (newVal==false) {
                      interested.remove(interests[4]);
                      user.update(newInterests: interested);
                    }
                  });
                },
              ),
              Text(interests[4]),
            ],
          ),
        ),
        //number 5
        Container(
          width: 125,
          height: 20,
          child: Row(
            children: <Widget>[
              Checkbox(
                value : bool_interest[5],
                onChanged: (bool newVal){
                  setState(() {
                    bool_interest[5]=newVal;
                    if(newVal==true) {
                      interested.add(interests[5]);
                      user.update(newInterests: interested);
                    }
                    else if (newVal==false) {
                      interested.remove(interests[5]);
                      user.update(newInterests: interested);
                    }
                  });
                },
              ),
              Text(interests[5]),
            ],
          ),
        ),
        //number 1
      ],
    );
  }


  Widget _saveButton(){
    return Align(
        alignment: Alignment.center,
        child : new RaisedButton(
            onPressed: goBack,
              color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.white),
            ),
            child : Text(
              "Save Edits",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
        )
    );
  }
}
