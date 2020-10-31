import 'package:ctrl_alt_elite/Screens/Chat.dart';
import 'package:ctrl_alt_elite/nav_bar.dart';
import 'package:flutter/material.dart';

class ChatCard extends StatefulWidget {
  String currentUser;
  ChatCard({this.currentUser});
  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor('#3AB83A'),
        title: Text(
          'Discussion forum',
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Card(
            elevation: 20,
            child: FlatButton(
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chat(
                            currentUser: currentUser,
                          )),
                );
              },
              child: Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/GroupLogo.png'),
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(80))),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Container(
                          child: Text(
                        'Group Chat',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ignore: missing_required_param
          Padding(
            padding: const EdgeInsets.all(100.0),
            child: Center(
              child: FloatingActionButton.extended(
                label: Text('Video call'),
                icon: Icon(Icons.video_call),
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
      // ignore: missing_required_param
    );
  }
}
