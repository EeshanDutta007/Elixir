import 'constants.dart';
import 'database1.dart';
import 'database.dart';
import 'widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';
import 'package:Elixir/About.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;

  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].data()["message"],
                    sendByMe: Constants.myName ==
                        snapshot.data.documents[index].data()["sendBy"],
                    h_message:
                        snapshot.data.documents[index].data()["h_message"],
                  );
                })
            : Container();
      },
    );
  }

  addMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      IamOptions options = await IamOptions(
              iamApiKey: "zPd4_juFPVV42husl_hmBH_oHgw90ktzPFVpkX-TdMfA",
              url:
                  "https://api.kr-seo.language-translator.watson.cloud.ibm.com/instances/1d7be1f0-3162-4a87-a954-7e7e6e154ff3")
          .build();
      LanguageTranslator service = new LanguageTranslator(iamOptions: options);
      TranslationResult translationResult = await service.translate(
          messageEditingController.text, Language.ENGLISH, Language.HINDI);
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        "h_message": translationResult.toString(),
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('ChatApp'),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.green, width: 2.0),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageEditingController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                      ),
                    )),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [Colors.green, Colors.green],
                                    begin: FractionalOffset.topLeft,
                                    end: FractionalOffset.bottomRight),
                                borderRadius: BorderRadius.circular(40)),
                            padding: EdgeInsets.all(12),
                            child: Image.asset(
                              "images/send.png",
                              height: 25,
                              width: 25,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  String message;
  String h_message = '';
  final bool sendByMe;

  MessageTile(
      {@required this.message,
      @required this.sendByMe,
      @required this.h_message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            sendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: sendByMe ? Color(0xff3AB83A) : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: k == 1
                  ? Text(message,
                      style: TextStyle(
                        color: sendByMe ? Colors.white : Colors.black,
                        fontSize: 15.0,
                      ))
                  : Text(
                      h_message,
                      style: TextStyle(
                        color: sendByMe ? Colors.white : Colors.black,
                        fontSize: 15.0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
