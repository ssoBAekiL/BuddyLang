import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class Storage {
  Future<String> get localPath async {
    final dir = await  getApplicationDocumentsDirectory();
    return dir.path;
  }
  Future<File> get localFile async {
    final path= await localPath;
    return File('$path/TextFiles/description.txt');
  }
  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();
      return body;
    } catch (e) {
      return e.toString();
    }
  }
    Future<File> writeData(String data) async{
      final file= await localFile;
      return file.writeAsString("$data");
    }
}

// end write and read on file

class MyCustomForm extends StatefulWidget {
  final Storage storage;
  MyCustomForm({Key key, @required this.storage}) : super(key: key);
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  final controller = TextEditingController();
  String state;
  Future<Directory> _appDocDir;

  @override
  void initState() {
    super.initState();
    widget.storage.readData().then((String value){
      setState(() {
        state=value;
      });
    });
  }

  Future<File> writeData() async {
    setState(() {
      state= controller.text;
      controller.text='';
    });
    return widget.storage.writeData(state);
  }

  @override
  Widget build(BuildContext context) {
  }
}
