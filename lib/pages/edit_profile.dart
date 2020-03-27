import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';

class EditProfile extends StatefulWidget {

  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();


  bool isLoading = false;
  User user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    //deserialize
     user = User.fromDocument(doc);
     displayNameController.text = user.displayName;
     bioController.text = user.bio; //to put the text immediatelly
  }



  @override
  Widget build(BuildContext context) {
    return Text('Edit Profile');
  }
}
