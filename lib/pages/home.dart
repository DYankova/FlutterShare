import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection("users");
final postRef = Firestore.instance.collection("post");

final timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;



 //listen if user is sign in
  @override
  void initState() {
    super.initState();
    pageController = PageController(); //despose it when we dont need it
        googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
          handleSignIn (account);
        }, onError: (err) {
          print(err);
    });
        //reauthenticate user when app open again

    googleSignIn.signInSilently(suppressErrors: false)
    .then((account) {
       handleSignIn (account);
    }).catchError((err) {
      print(err);
    });
  }

  handleSignIn(GoogleSignInAccount account){
    if (account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async{
    //1.check if user exists to id in DB
    final GoogleSignInAccount user =  googleSignIn.currentUser;
     DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists){
      //2.if doesnt exist we want to create it to create accoutnt page
     final username  = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount())); //to come back here

    //3. get username to create account , make new user document in user collection
     usersRef.document(user.id).setData({
       "id" : user.id,
       "username" : username,
       "photoUrl" : user.photoUrl,
       "email" : user.email,
       "bio" : "",
       "timestamp" : timestamp //now
     });
     doc = await usersRef.document(user.id).get(); //refectch it!!!
    }
    //to deserialize it
    currentUser =  User.fromDocument(doc); // to be able to pass it in diff pages
     print(currentUser);
  }


  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login(){
    googleSignIn.signIn();
  }

  logout(){
    googleSignIn.signOut();
  }

  onPagedChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex){
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
    );
  }

  Scaffold buildsAuthScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
        RaisedButton(
           child: Text('Logout'),
           onPressed: logout,
        ),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPagedChanged,
        physics: NeverScrollableScrollPhysics(), //not scroll
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon : Icon(Icons.whatshot),),
          BottomNavigationBarItem(icon : Icon(Icons.notifications_active),),
          BottomNavigationBarItem(icon : Icon(Icons.photo_camera, size: 35.0,),),
          BottomNavigationBarItem(icon : Icon(Icons.search),),
          BottomNavigationBarItem(icon : Icon(Icons.account_circle),),
        ],
      ),
    );
//
  }

  buildsUnAuthScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ]
          )
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Fluttershare',
            style: TextStyle(
              fontFamily: "Signatra",
              fontSize: 50.0,
              color: Colors.white,
            ),
            ),
            GestureDetector(
              onTap: login(),
              child: Container(
                width: 200.0,
                  height: 70.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildsAuthScreen() : buildsUnAuthScreen();
  }
}
