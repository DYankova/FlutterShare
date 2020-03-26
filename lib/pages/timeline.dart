import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

final usersRef = Firestore.instance.collection('users');
class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();

}


class _TimelineState extends State<Timeline> {

  @override
  void initState() {
//    createuser();
  //updateUser();
    // deleteUser()
    super.initState();
  }

//  createuser(){
//    usersRef.document("udhfhjaaodoo").setData({
//      "username" : "Fif",
//      "postCount": 0,
//      "isAdmin": false,
//    });
//  }

//  updateUser() async {
//   final doc = await  usersRef.document("udhfhjaaodoo").get();
//   if (doc.exists) {
//     doc.reference.updateData({
//       "username" : "John",
//       "postCount": 0,
//       "isAdmin": false,
//     });
//   }
//  }

//  deleteUser()async {
//    final DocumentSnapshot doc = await  usersRef.document("udhfhjaaodoo").get();
//    if (doc.exists) {
//      doc.reference.delete();
//    }
//  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: Text('Timeline'),
//      StreamBuilder<QuerySnapshot>(//resolve future directly just in State
//        stream: usersRef.snapshots(),
//        builder: (context, snapshot){
//          if (!snapshot.hasData) {
//            return circularProgress(); //if still fetching
//          }
//          final List<Text>children = snapshot.data.documents.map((doc) => Text(doc['username'])).toList();
//          return  Container(
//              child: ListView(
//              children: children,
//            ),
//          );
//        },
//      ),
    );
  }
}
