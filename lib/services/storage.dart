/******************************/
/*          BuddyLang         */
/*  Author: Pablo Borrelli    */
/******************************/

import 'dart:io';
import 'package:buddylang/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';


class StorageService {
  static final FirebaseStorage _reference =
    FirebaseStorage(storageBucket: 'gs://fir-buddylang.appspot.com/'); // reference to firebase storage main folder
  static final StorageReference _userImageReference =
    FirebaseStorage(storageBucket: 'gs://fir-buddylang.appspot.com/').ref().child('userImages'); // reference to firebase storage profile pictures folder
  static final StorageReference _userBackgroundImageReference =
    FirebaseStorage(storageBucket: 'gs://fir-buddylang.appspot.com/').ref().child('userBackgroundImages'); // reference to firebase storage user's background images folder

  /*  Function that receives a File object and a filename and calls the     */
  /*  function that uploads to the firebase storage profile images folder.  */
  /*  After the upload is completed waits and returns the image's url       */
  static void uploadUserImage(File file, String filename, User u) async {
    await _uploadImage(file, filename, _userImageReference).then((url) => u.update(newProfileImageUrl: url));
  }

  /*  Function that receives a File object and a filename and calls the function  */
  /*  that uploads to the firebase storage user's background images folder.       */
  /*  After the upload is completed waits and returns the image's url             */
  static void uploadUserBackgroundImage(File file, String filename, User u) async {
    await _uploadImage(file, filename, _userBackgroundImageReference).then((url) => u.update(newBackgroundImageUrl: url));
  }

  /*  Function that given a StorageReference actually takes care of uploading any image */
  static Future<String> _uploadImage(File file, String filename, StorageReference reference) async {
    final StorageUploadTask uploadTask = reference.child('$filename.jpg').putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print(url);
    return url;
  }

  /*  USED FOR TESTING, PROBABLY WILL BE DELETED  */
  static Future<void> getImageUrl(String name) async {
    print(await _userImageReference.child(name).getDownloadURL());
  }
}