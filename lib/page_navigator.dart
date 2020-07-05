import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mulakaat/video_room.dart';
// import 'package:videoconf/video_room.dart';
import 'Auth/auth.dart';
import 'groups_page.dart';
import 'chat_page.dart';
import 'package:provider/provider.dart';
import 'Model/user.dart';

class PageNavigator extends StatefulWidget {
  PageNavigator();

  @override
  PageNavigatorState createState() => PageNavigatorState();
}

class PageNavigatorState extends State<PageNavigator> {
  AuthService _auth = AuthService();

  String selectedGroupID;
  String selectedGroupName;
  PageController controller = PageController(initialPage: 0);

  Firestore _firestore = Firestore.instance;

  String newUsername;
  String newImageURL;

  bool dialogueUp = false;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);

    // Enter username/image dialogue
    Future.delayed(Duration(seconds: dialogueUp ? 3 : 0), () {
      _firestore.collection('Users').document(user.uid).get().then((doc) {
        if (doc.exists && doc.data['username'] != null) {
          print("user exists");
          print("username: " + doc.data['username']);
          user.userName = doc.data['username'];
          user.picture = doc.data['picture'];
          dialogueUp = true;
          // setState(() {
          //   dialogueUp = true;
          // });

        } else if (!dialogueUp) {
          dialogueUp = true;
          print("user does not exist");
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 24.0,
              title: Text(
                "Choose Username",
                style: TextStyle(color: Colors.lightBlue),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Username',
                      ),
                      onChanged: (value) {
                        newUsername = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Image URL',
                      ),
                      onChanged: (value) {
                        newImageURL = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Done"),
                  onPressed: () {
                    _firestore.collection("Users").document(user.uid).setData({
                      'username': newUsername,
                      'picture': newImageURL,
                    });
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    user.userName = newUsername;
                    user.picture = newImageURL;
                    User u = Provider.of<User>(context);
                    print('username: ' + u.userName);
                    Navigator.of(context).pop();
                    setState(() {
                      dialogueUp = true;
                    });
                  },
                ),
              ],
            ),
            barrierDismissible: true,
          );
        }
      });
    });

    // main PageView, contains group page, chat page, and video room
    return PageView(
      scrollDirection: Axis.horizontal,
      controller: controller,
      children: <Widget>[
        //Page 1: Group Selection
        GroupsPage(this),
        //Page 2: Text Chat
        Container(
          child: ChatPage(
            groupId: selectedGroupID,
            groupName: selectedGroupName,
            user: user,
            pageNavigatorState: this,
          ),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(),
            ),
            shadows: [new BoxShadow(blurRadius: 5.0)],
          ),
        ),
        //Page 3: Video Room
        Container(
          child: VideoRoom(
            groupId: selectedGroupID == null ? "test" : selectedGroupID,
            pageNavigatorState: this,
          ),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(),
            ),
            shadows: [new BoxShadow(blurRadius: 5.0)],
          ),
        ),
      ],
    );
  }

  // Used in other pages to set the selected page of the PageView
  void setPage(int page) {
    controller.animateToPage(page,
        duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
  }
}
