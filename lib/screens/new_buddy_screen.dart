/******************************/
/*          BuddyLang         */
/*  Author: Pablo Borrelli    */
/******************************/

import 'dart:math';
import 'package:buddylang/models/user.dart';
import 'package:buddylang/screens/navigation_screen.dart';
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

  _showNotFoundAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No buddy avaliable"),
          content: Text(
              "We are sorry, we couldn't find any avaliable buddy matching your search.\n\nTry again later or change your searching parameters."),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

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
        _buddySelection(users).then((newBuddy) {
          if (newBuddy != null) {
            // Chat([User.uid, u.reference.documentID]).saveNewChat();
            setState(() {
              NavigationScreen.currentIndex = 1;
            });
            Navigator.pushNamed(context, '/profileScreen', arguments: {
              'uid': newBuddy.reference.documentID,
              'edit': false,
              'newBuddy': true
            });
          } else
            _showNotFoundAlert(context);
        });
      });
  }

  Future<User> _buddySelection(QuerySnapshot users) {
    List<User> buddys = [];
    User newBuddy;
    if (users.documents.isNotEmpty) {
      users.documents.forEach((u) => buddys.add(User.fromSnapshot(u)));
      buddys.removeWhere((buddy) => buddy.reference.documentID == User.uid);
      return DatabaseService().getUser(User.uid).then((snapshot) {
        User self = User.fromSnapshot(snapshot);
        buddys.removeWhere(
            (buddy) => self.buddys.contains(buddy.reference.documentID));

        if (buddys.length == 0)
          return null;
        else if (buddys.length == 1)
          newBuddy = buddys[0];
        else if (_dropdownInterest != null) {
          if (buddys
                  .where((buddy) => buddy.interests.contains(_dropdownInterest))
                  .toList()
                  .length >
              0) {
            buddys.removeWhere((buddy) =>
                buddy.interests.contains(_dropdownInterest) == false);
          }
        }
        if (buddys.length > 1)
          newBuddy = buddys[Random().nextInt(buddys.length)];
        else
          newBuddy = buddys[0];
        return newBuddy;
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'Find new buddy',
              style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 28),
            ),
            centerTitle: true,
            backgroundColor: Color(0xFF73AEF5)),
        backgroundColor: Colors.grey[100],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(1.0, 10.0, 1.0, 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          child: Center(
                            child: Text(
                              'Choose the language you want to practice\n\n' +
                                  'Choose the topic you want to discus\n\n' +
                                  'Get ready for a new amazing conversation!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
                        child: Text('Language:',
                            style: TextStyle(fontSize: 20.0)),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _dropdownLanguage,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Color(0xFF73AEF5),
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
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
                        child: Text('Interest:',
                            style: TextStyle(fontSize: 20.0)),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _dropdownInterest,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Color(0xFF73AEF5),
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
                      ),
                      Center(
                        child: RaisedButton(
                            color: Color(0xFF73AEF5),
                            child: Text('New buddy!'),
                            onPressed: () => _searchBuddy(context)),
                      ),
                      Expanded(
                        child: Align(
                          child: Image(
                              image: AssetImage('assets/images/buddys.png')),
                          alignment: FractionalOffset.bottomCenter,
                        ),
                      )
                    ],
                  ),
                );
              }
            }));
  }
}
