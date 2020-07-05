import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:buddylang/myfunctions.dart';
import "LanguagesHandler.dart";
import 'dart:io';

class Settings extends StatefulWidget{
@override
_SettingsState createState () => _SettingsState();
}

class _SettingsState extends State <Settings> {
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  FocusNode node = FocusNode();
  String description_='';
  String languages_='';
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
            child : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Align(
                          alignment : Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width*0.99,
                            height: MediaQuery.of(context).size.height*0.49,
                            child : GestureDetector(
                              //onTap: getImage,
                              child : _image == null
                                ? CircleAvatar(
                                backgroundImage: AssetImage('assets/images/empty_profile.jpg'),
                                maxRadius: 150,
                                )
                                : CircleAvatar(
                                backgroundImage: FileImage(_image),
                                maxRadius: 80),
                            ),
                          ),
                        ),
                      ],
                  ),
                Row(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width*0.99,
                          height: MediaQuery.of(context).size.height*0.49,
                          child : Align(
                            alignment: Alignment.center,
                            child: TextField(
                              onChanged: (text) {
                                description_=text;
                              },
                            //per non far cambiare la tastiera vedi riga sotto
                            //keyboardType: TextInputType.text,
                            enabled : false,
                            maxLines: null,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "Tell us something about you...",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.yellowAccent,
                                  width: 3.0,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                              labelText: 'Descrizione:',
                            ),
                            ),
                          ),
                        ),
                      ),
                    ],
                ),
          new Row(
            children: <Widget>[
              Row(
                children : <Widget> [
                  Align(
                    alignment: Alignment.topCenter,
                    child : SizedBox(
                    width: MediaQuery.of(context).size.width*0.9,
                    height: MediaQuery.of(context).size.height*0.49,
                    child: TextField(
                      minLines: 1,
                      maxLines: 3,
                      enabled: false,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                        labelText: 'Spoken languages : ',
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.yellowAccent,
                            width: 3.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                    ),
                ],
              ),
            ],
          ),
                    new Row(
                      children: <Widget>[
                        Row(
                          children : <Widget> [
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.9,
                              height: MediaQuery.of(context).size.height*0.4,
                              child: TextField(
                                minLines: 1,
                                maxLines: 3,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                  ),
                                  labelText: 'Interests : ',
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.yellowAccent,
                                      width: 3.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
          ),
              ),
          ),
    );
  }
}