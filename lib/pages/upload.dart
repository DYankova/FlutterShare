
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';


class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  TextEditingController captionController = TextEditingController();//for the created post in firestore
  TextEditingController locationController = TextEditingController();
   File file;
   bool isUploading  = false;
   String postId = Uuid().v4(); //autocreate uniq id

  handleTakePhoto() async{
    Navigator.pop(context);
    File file= await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 675,
    maxWidth: 960);
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGalery()async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext){
    //display a module, dialog
    return showDialog(
      context: parentContext,
      builder: (context){
        return SimpleDialog(
          title: Text("Create post"),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Photo from Camera"),
                onPressed: handleTakePhoto
            ),
            SimpleDialogOption(
              child: Text("From galery"),
                onPressed:  handleChooseFromGalery
            ),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }
    );
  }


  Container buildSplashScreen(){
      return Container(
        color: Theme.of(context).accentColor.withOpacity(0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/upload.svg',height: 250.0),
            Padding(padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Text("Upload Image",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              ),),
              color: Colors.deepOrangeAccent,
              onPressed: () => selectImage(context),
            ),)
          ],
      ),
      );
  }


  clearImage(){
    setState(() {
      file = null;
    });
  }

  Future <String>uploadImage(imageFile)async {
     StorageUploadTask uploadTask =  storageRef.child("post_$postId.jpg").putFile(imageFile);
     StorageTaskSnapshot storageSnap =  await uploadTask.onComplete; //snapshot return
     String downloadUrl = await storageSnap.ref.getDownloadURL();
     return downloadUrl;
  }

  createPostInFirestore({ String mediaURl, String location, String description}){
    //loc, caption
    postRef
        .document(widget.currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
          "postId" :postId,
          "ownerId" :widget.currentUser.id,
          "username": widget.currentUser.username,
          "mediaUrl": mediaURl,
          "location" : location,
          "timestamp": timestamp,
          "description": description,
          "likes" : {},
         });
  }


  handleSubmit() async{
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file); //getting back after compressing and uploading
    createPostInFirestore(
      mediaURl: mediaUrl,
      location: locationController.text,
      description: captionController.text
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading  = false; //when it is uploaded, change also Rules in firestore
    });
  }

  //compress images fo add them to Firebase
  compressImage() async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    //from image.io
     Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
     //compressed image file
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 80));

    setState(() {
      file = compressedImageFile;
    });
  }

  Scaffold buildUploadForm(){
   return Scaffold(
     appBar: AppBar(
       backgroundColor:  Colors.white,
       leading: IconButton(
         icon: Icon(Icons.arrow_back, color: Colors.black),
         onPressed: clearImage,
       ),
       title: Text("Caption Post",
       style: TextStyle(
           color: Colors.black
       ),),
       actions: <Widget>[
         FlatButton(
           onPressed: isUploading ? null : () => handleSubmit(),
           child: Text("Post",
           style: TextStyle(
             color: Colors.lightBlueAccent,
             fontWeight: FontWeight.bold,
             fontSize: 20.0
           ),),
         )
       ],
     ),
     body: ListView(
       children: <Widget>[
         isUploading ? linearProgress() : Text(""),
         Container(
           height: 220,
           width: MediaQuery.of(context).size.width * 0.8, //80% of screen
           child: Center(
             child: AspectRatio(
               aspectRatio: 16 / 9, //ratio
               child: Container(
                 decoration: BoxDecoration(
                   image: DecorationImage(
                     fit: BoxFit.cover,
                     image: FileImage(file),
                   )
                 ),
               ),
             ),
           ),
         ),
         Padding(
           padding: EdgeInsets.only(top: 10.0),
         ),
         ListTile(
           leading: CircleAvatar(
             backgroundImage: CachedNetworkImageProvider(
               widget.currentUser.photoUrl),
             ) ,
           title: Container(
           width: 250.0,
             child: TextField(
               controller:  captionController,
               decoration: InputDecoration(
                 hintText: "Write a caption...",
                 border:  InputBorder.none,

               ),
             ),
           ),
         ),
         Divider(),
         ListTile(
           leading: Icon(Icons.pin_drop, color: Colors.deepOrangeAccent,size: 35.0,),
           title: Container(
             width: 250.0,
             child: TextField(
               controller:  locationController,//for creating a post
               decoration: InputDecoration(
                 hintText: "Where was this nice photo taken?",
                 border: InputBorder.none
               ),
             ),
           ),
         ),
         Container(
           width: 200.0,
           height: 100.0,
           alignment: Alignment.center,
           color: Colors.blue,
           child: RaisedButton.icon(
             label: Text("Use current location",
                 style: TextStyle(color: Colors.white),
                 ),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(30.0)
           ),
             color: Colors.blue,
             onPressed: getUserLOcation,
           icon: Icon(
             Icons.my_location,
             color: Colors.white,
           ),
           ),


         )
       ],
     ),
   );
  }

  getUserLOcation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy:  LocationAccuracy.high); //how good is location
    List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formattedAddress =  "${placemark.locality}";
    locationController.text = formattedAddress;
  }


  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
