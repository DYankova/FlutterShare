import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';

class Post extends StatefulWidget {// a post model in the widget
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({this.postId, this.ownerId, this.username, this.location, this.description, this.mediaUrl, this.likes});

  //to get a post
  factory  Post.fromDocument(DocumentSnapshot doc){
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes){
    //if no likes = 0
    if(likes == null){
      return 0;
    }
    int count = 0;
    //if the key is set to true, add a like
    likes.values.forEach((val){
      if(val == true ) {
        count += 1;
      }
    });
  }

//not used!!!!!!!!!!!!!!!!!!!!!!!!!!!
  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    location: this.location,
    description: this.description,
    mediaUrl: this.mediaUrl,
    likes: this.likes,
    likesCount: getLikeCount(this.likes)

  );

}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likesCount = 0 ;//not final because they will be updated
  Map likes;

  _PostState({this.postId, this.ownerId, this.username, this.location,
    this.description, this.mediaUrl, this.likes, this.likesCount});

  buildPostHeader(){
    return FutureBuilder( //get user data
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        //deserialize
       User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
            ),
           title: GestureDetector(
//             onTap: ,
            child: Text(
            user.username,
            style: TextStyle(
             color: Colors.black
           ),
        ),
      ),
          subtitle: Text(
            location),
          trailing: IconButton(
//            onPressed: (),
            icon: Icon(Icons.more_vert),
          ),
    );
   },
  );
  }

  buildPostImage(){//tap twice on the image
    return GestureDetector(
//      onDoubleTap: () => print("like the post);
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(mediaUrl),
        ],
    )
    );
  }

  buildPostFooter(){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0)),
              GestureDetector(
//                onTap: ,
                child: Icon(
                  Icons.favorite_border,
                  size: 28.0,
                  color: Colors.pink,
                ),
            ),
            Padding(
                padding: EdgeInsets.only(right: 20.0)),
                GestureDetector(
  //                onTap: ,
                  child: Icon(
                    Icons.chat,
                    size: 28.0,
                    color: Colors.blueAccent,
                  ),
              ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likesCount likes",
                style: TextStyle(
                  color:  Colors.black,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username ",
                style: TextStyle(
                    color:  Colors.black,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            Expanded(child: Text(description),)
          ],
        ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter()
      ],
    );
  }
}
