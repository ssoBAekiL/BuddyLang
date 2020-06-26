import 'dart:math';

import 'package:buddylang/models/user.dart';
import 'package:buddylang/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewBuddyScreen extends StatefulWidget {
  @override
  _NewBuddyScreenState createState() => _NewBuddyScreenState();
}

class _NewBuddyScreenState extends State<NewBuddyScreen> {
  String _dropdownLanguage;
  String _dropdownInterest;
  User user;

  String testText = '';

  void _searchBuddy(BuildContext context) {
    if (_dropdownLanguage == null) {
      final snackBar =
          SnackBar(content: Text('Select the language you want to use'));
      Scaffold.of(context).showSnackBar(snackBar);
    } else if (_dropdownLanguage == 'No avaliable languages') {
      final snackBar =
          SnackBar(content: Text('Update your profile to add a language'));
      Scaffold.of(context).showSnackBar(snackBar);
    } else
      DatabaseService()
          .getNewBuddy(_dropdownLanguage)
          .then((QuerySnapshot users) {
        User u = _buddySelection(users);
        if (u != null)
          print('new user $u');
        else {
          final snackBar = SnackBar(
              content: Text(
                  'We are sorry, no matching user was found. Please try later or change your preferences'));
          Scaffold.of(context).showSnackBar(snackBar);
        }
      });
  }

  User _buddySelection(QuerySnapshot users) {
    List<User> buddys = [];
    User newBuddy;
    if (users.documents.isNotEmpty) {
      users.documents.forEach((u) => buddys.add(User.fromSnapshot(u)));
      buddys.removeWhere((buddy) => buddy.reference.documentID == User.uid);
      if (buddys.length == 1)
        newBuddy = buddys[0];
      else if (_dropdownInterest != null) {
        if (buddys.where((buddy) => buddy.interests.contains(_dropdownInterest)).toList().length > 0) {
          buddys.removeWhere(
            (buddy) => buddy.interests.contains(_dropdownInterest) == false);
        }
      }
      if (buddys.length > 1)
        newBuddy = buddys[Random().nextInt(buddys.length)];
      else newBuddy = buddys[0];

      setState(() {
        testText = newBuddy.toString();
      });
      return newBuddy;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Find new buddy'),
            centerTitle: true,
            backgroundColor: Colors.lightBlue[600]),
        body: StreamBuilder(
            stream: DatabaseService().getUserStream(User.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              else {
                user = User.fromSnapshot(snapshot.data);
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(35.0, 0, 35.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 10.0),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.lightBlue),
                          child: Center(
                            child: Text(
                              'Find a buddy and\nstart a new conversation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 60.0),
                        Text('Language in common:',
                            style: TextStyle(fontSize: 20.0)),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: _dropdownLanguage,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.lightBlue[600],
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              _dropdownLanguage = newValue;
                            });
                          },
                          items: (user.languages != null
                                  ? user.languages
                                  : <String>['No avaliable languages'])
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10.0),
                        Text('Main interest:',
                            style: TextStyle(fontSize: 20.0)),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: _dropdownInterest,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.lightBlue[600],
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              _dropdownInterest = newValue;
                            });
                          },
                          items: (user.interests != null
                                  ? user.interests
                                  : <String>['No avaliable interests'])
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        Center(
                          child: RaisedButton(
                              color: Colors.lightBlue[500],
                              child: Text('Search'),
                              onPressed: () => _searchBuddy(context)),
                        ),
                        Text(testText),
                      ],
                    ),
                  ),
                );
              }
            }));
  }
}
