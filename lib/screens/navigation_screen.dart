import 'package:buddylang/screens/conversations_screen.dart';
import 'package:buddylang/screens/new_buddy_screen.dart';
import 'package:buddylang/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavigationScreen extends StatefulWidget {
  static int currentIndex = 1;
  NavigationScreen({Key key}) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  
  final tabs = [ProfileScreen(), ConversationsScreen(), NewBuddyScreen()];

  Future<bool> _onBackPressed() {
    if (NavigationScreen.currentIndex != 1) {
      setState(() {
        NavigationScreen.currentIndex = 1;
      });
    }
    else {
      return showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      title: new Text('Are you sure?'),
      content: new Text('Do you really want to exit BuddyLang?'),
      actions: <Widget>[
        new GestureDetector(
          onTap: () => Navigator.of(context).pop(false),
          child: Padding(padding: EdgeInsets.all(8.0),
            child: Text("No")),
        ),
        SizedBox(height: 16),
        new GestureDetector(
          onTap: () => SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
            child: Text("Exit"),
          ),
        ),
      ],
    ),
  ) ??
      false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: tabs[NavigationScreen.currentIndex],
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: NavigationScreen.currentIndex,
            selectedItemColor: Colors.black,
            backgroundColor: Colors.lightBlue[600],
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), title: Text('Profile')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat), title: Text('Conversations')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.add_comment), title: Text('Find buddy'))
            ],
            onTap: (index) {
              setState(() {
                NavigationScreen.currentIndex = index;
              });
            }),
      ),
    );
  }
}
