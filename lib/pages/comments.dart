import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'home.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({this.postId, this.postMediaUrl, this.postOwnerId});

  @override
  CommentsState createState() => CommentsState(
    postId: this.postId,
    postOwnerId: this.postOwnerId,
    postMediaUrl: this.postMediaUrl,
  );
}

class CommentsState extends State<Comments> {

  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  TextEditingController commentsController = TextEditingController();

  CommentsState({this.postId, this.postMediaUrl, this.postOwnerId});

  buildComments(){
    //to be realtim
    return StreamBuilder(
      stream: commentsRef
          .document(postId)
          .collection('comments')
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        //deserialize
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
        comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children:  comments,
        );
      });
  }


  addComment(){
    commentsRef
    .document(postId)
        .collection("comments")
        .add({
          "username":currentUser.username,
          "comment" :commentsController.text,
          "timestamp": timestamp,
          "avatarUrl": currentUser.photoUrl,
          "userId": currentUser.id,
        });
    commentsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
           title: TextFormField(
           controller: commentsController,
           decoration: InputDecoration(labelText: "Write a comment..."),

          ),
             trailing: OutlineButton(
               onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text("Post"),
             ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({this.username, this.userId, this.avatarUrl, this.comment, this.timestamp});

  //factory = static
  factory Comment.fromDocument(DocumentSnapshot doc){
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
         leading: CircleAvatar(
           backgroundImage: CachedNetworkImageProvider(avatarUrl),
         ),
          subtitle: Text(timeago.format(timestamp.toDate()))//library,
        ),
      Divider(),
      ],
    );
  }

}
