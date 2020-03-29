import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';

void main() {
  //tell firestore to configure to use timestamps
  Firestore.instance.settings(timestampsInSnapshotsEnabled:  true)
  .then((_) {
    print("Timestamps enabled in snapshots succesfully");
  }, onError: (_){
    print("Error in timestamps");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pinkAccent,
        accentColor: Colors.amber
      ),
      home: Home(),
    );
  }
}
