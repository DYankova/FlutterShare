import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey(); //to display snackbar
  final _formKey = GlobalKey<FormState>(); //for saving text in form
  String username;

  submit() {
    final form =  _formKey.currentState;
    if (form.validate()){
      form.save();
      SnackBar snackBar = SnackBar(content: Text(
        "Welcome $username!"));
      _scaffoldKey.currentState.showSnackBar(snackBar);

      Timer(Duration(seconds: 2), (){ //to show the snackbar for 2 seconds
        Navigator.pop(context, username);
      });

    }
    //coming back to home
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key:  _scaffoldKey,
      appBar: header(context, titleText : "Set up your profile", removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text("Create a username", style:  TextStyle(
                    fontSize: 25.0
                  ),),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child: Form(
                    autovalidate: true,
                    key: _formKey,
                    child: TextFormField(
                      validator: (val){
                        if (val.isEmpty){
                          return 'Username too short';
                        }
                      },
                      onSaved: (val) => username = val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Username",
                        labelStyle: TextStyle(
                          fontSize: 15.0),
                          hintText: "Must be at least 3 characters",
                        ),
                      ),
                    ),
                  ),
                ),
                  GestureDetector(
                    onTap: submit,
                    child: Container(
                      height: 50.0,
                      width: 350.0,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Center(child:
                        Text("Submit", style: TextStyle(color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold
                      ),),
                      ),
                    ),
              ),
            ],),
          )
        ],

      ),

      );
  }
}
