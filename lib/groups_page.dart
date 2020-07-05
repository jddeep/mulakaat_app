import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:mulakaat/page_navigator.dart';
import 'Auth/auth.dart';
import 'GeoLocation/maps.dart';
import 'i18n/i18n.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

class GroupsPage extends StatefulWidget {
  final PageNavigatorState pageNavigatorState;

  GroupsPage(this.pageNavigatorState);

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> with AutomaticKeepAliveClientMixin<GroupsPage>{

  @override
  bool get wantKeepAlive => true;
  
  Firestore _firestore = Firestore.instance;
  var newGroupName = "";

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async{
        await SystemNavigator.pop();
        return true;
      },
      child:Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: Text(
          FlutterI18n.translate(context, 'app.rooms'),
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700, 
            color: Colors.white,
            fontFamily: 'Montserrat'
          ),
        ),
        elevation: 5.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 24.0,
                  title: Text(FlutterI18n.translate(context, 'app.newgroup'), style: TextStyle(color: Colors.green, fontFamily: 'Montserrat', fontWeight: FontWeight.w600),),
                  content: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: FlutterI18n.translate(context, 'app.groupname'),
                    ),
                    onChanged: (value){
                      newGroupName = value;
                    },
                  ),
                  
                  actions: <Widget>[
                    FlatButton(
                      child: Text(FlutterI18n.translate(context, 'app.creategroup'), style: TextStyle(fontFamily: 'Montserrat', color: Colors.green, fontWeight: FontWeight.w400),), // newgroup in i18n
                      onPressed: (){
                        _firestore.collection("Groups").add({
                          'groupName': newGroupName,
                          'picture': '',
                        });
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                      },
                    ),
                  ],
                ),
                barrierDismissible: true,
              );
            },
          ),
          
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("Groups").snapshots(),
              builder: (context,snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                    return Center(child:CircularProgressIndicator());
                  default:
                    return ListView(
                      children: makeListWidget(snapshot),
                    );
                }
              },
            ),
          ),
        ],
      ),

      //Adding a drawer
      drawer: Drawer(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.orange,
            title: Text(FlutterI18n.translate(context, 'app.extras'), style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body:ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              // ListTile(
              //   title: Text(FlutterI18n.translate(context, 'app.maps'),  style: TextStyle(fontFamily: 'Montserrat'),),
              //   onTap: () {
              //     // Update the state of the app.
              //     // ...
              //     print(sayLocation());

              //     Navigator.push(
              //       context, 
              //       MaterialPageRoute(builder: (context) => MapsPage()),
              //     );
              //   },
              // ),
              // ListTile(
              //   title: Text(FlutterI18n.translate(context, 'app.analytics')),
              //   onTap: () {
              //     // Update the state of the app.
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => Chart()));
              //   },
              // ),
              
              ListTile(
                leading: Icon(Icons.person, color: Colors.black,),
                title: Text(FlutterI18n.translate(context, 'app.logout'), style: TextStyle(color: Colors.black, fontFamily: 'Montserrat')),
                onTap: () async{
                  showSimpleFlushBar(context, FlutterI18n.translate(context, 'app.successfullysignedout'));
                  await _auth.signOut();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                title: Text('Language Settings', style: TextStyle(color: Colors.black, fontFamily: 'Montserrat')),
                onTap: (){
                    // go to i18n selection page
                    print('Settings button pressed, going to i18n page');
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => InternationalizationPage()),
                    );
                  },
              )
            ],
          ),
        ),
      ),
      ),
    );
  }

  List<Widget> makeListWidget(AsyncSnapshot snapshot){
    return snapshot.data.documents.map<Widget>((document){
      return ListTile(
        onTap: () {
          showSimpleFlushBar(context, 'Selected ${document["groupName"]}');
          print('onTap, setting selectedGroupID to ${document["groupName"]}');
          widget.pageNavigatorState.selectedGroupID = document.documentID;
          widget.pageNavigatorState.selectedGroupName = document.data['groupName'];
          widget.pageNavigatorState.setState((){});
          widget.pageNavigatorState.setPage(1);
        },
        leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: Colors.green,
          child: Icon(Icons.ondemand_video, color: Colors.white,),
          // backgroundImage: NetworkImage(document["picture"]) != null? NetworkImage(document["picture"]) : null,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(document["groupName"],
              textAlign: TextAlign.center,
              style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(width: 16.0),
            Text(
              document['time'] != null ? document['time'] : " ",
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 10.0,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: <Widget>[
            Text((document['lastUser'] != null ? document['lastUser'] : " " )+ ": ",  style: TextStyle(fontFamily: 'Montserrat'),),
            Text((document['lastMessage'] != null? document['lastMessage'] : " "), style: TextStyle(fontFamily: 'Montserrat'),),
          ],
        )
      );
    }).toList();
  }

  //Simple flushbar
  void showSimpleFlushBar(BuildContext context, String message){
    Flushbar(
      message: message,
      duration: Duration(seconds: 1),
    )..show(context);
  }
}

