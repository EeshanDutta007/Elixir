import 'Getinfo.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';

String email;
File _imageFile;
int a = 0;
Future<void> currentUserEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  email = prefs.getString('email');
}

// ignore: deprecated_member_use
final _firestore = Firestore.instance;

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Center(child: Text('Feed')),
        leading: null,
        backgroundColor: Colors.green[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            RaisedButton(
              child: Container(width: 100, child: Icon(Icons.add)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GetInfo()),
                );
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100))),
              color: Colors.green,
            ),
            Container(
              height: 60,
            )
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatefulWidget {
  @override
  _MessagesStreamState createState() => _MessagesStreamState();
}

class _MessagesStreamState extends State<MessagesStream> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('blogs')
          .orderBy('time', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.green[600],
            ),
          );
        }
        // ignore: deprecated_member_use
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data()['text'];
          final messageSender = message.data()['sender'];

          String currentUser = email;
          currentUserEmail();
          final messageBubble = MessageBubble(
            sender: " ",
            text: messageText,
            isMe: email.toString() == messageSender,
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatefulWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  String sender;
  String text;
  final bool isMe;

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  String out;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
              child: Material(
                borderRadius: widget.isMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        bottomLeft: Radius.circular(5.0),
                        topRight: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0))
                    : BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        bottomLeft: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0),
                        topRight: Radius.circular(5.0),
                      ),
                elevation: 5.0,
                color: widget.isMe ? Colors.green[600] : Colors.white,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: widget.text.substring(
                                  widget.text.length - 4, widget.text.length) ==
                              '.jpg' ||
                          widget.text.substring(
                                  widget.text.length - 4, widget.text.length) ==
                              '.png' ||
                          widget.text.substring(
                                  widget.text.length - 5, widget.text.length) ==
                              '.jpeg'
                      ? Image.network(
                          widget.text,
                        )
                      : Center(
                          child: Text(
                            widget.text,
                            style: TextStyle(
                              color: widget.isMe ? Colors.white : Colors.black,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageUpload extends StatelessWidget {
  @override
  File imagefile;
  ImageUpload({this.imagefile});
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: ImageCapture(file: imagefile),
    );
  }
}

class ImageCapture extends StatefulWidget {
  final File file;

  ImageCapture({Key key, this.file}) : super(key: key);
  createState() => _ImageCaptureState(file);
}

class _ImageCaptureState extends State<ImageCapture> {
  File _imageFile;
  _ImageCaptureState(this._imageFile);

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _imageFile = croppedFile;
      setState(() {
        _imageFile = croppedFile ?? _imageFile;
      });
    }
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffeebe7),
      appBar: AppBar(
        title: Center(child: Text('Selected Image')),
        backgroundColor: Colors.green[600],
        leading: IconButton(icon: Icon(Icons.close), onPressed: _clear),
        actions: [IconButton(icon: Icon(Icons.crop), onPressed: _cropImage)],
      ),
      body: ListView(
        children: <Widget>[
          if (_imageFile != null) ...[
            Container(
                padding: EdgeInsets.all(32), child: Image.file(_imageFile)),
            Center(
              child: Uploader(
                file: _imageFile,
              ),
            )
          ]
        ],
      ),
    );
  }
}

/// Widget used to handle the management of
class Uploader extends StatefulWidget {
  final File file;

  Uploader({Key key, this.file}) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://ctrl-alt-elite-bd79d.appspot.com');

  StorageUploadTask _uploadTask;

  _startUpload() {
    String filePath = 'images/${DateTime.now()}.jpeg';
    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
      final StorageReference ref =
          FirebaseStorage.instance.ref().child(filePath);
    });
  }

  Future addurlinfirebase() async {
    StorageTaskSnapshot taskSnapshot = await _uploadTask.onComplete;
    final String url = (await taskSnapshot.ref.getDownloadURL());
    _firestore.collection('messages').add({
      'text': '$url.jpeg',
      'sender': email,
      'time': DateTime.now(),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (context, snapshot) {
            var event = snapshot?.data?.snapshot;

            double progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_uploadTask.isComplete)
                    Text('Uploaded',
                        style: TextStyle(
                            color: Colors.green[600], height: 2, fontSize: 30)),
                  if (_uploadTask.isPaused)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: FlatButton(
                        child: Icon(Icons.play_arrow,
                            size: 50, color: Colors.green[600]),
                        onPressed: _uploadTask.resume,
                      ),
                    ),
                  if (_uploadTask.isInProgress)
                    FlatButton(
                      child:
                          Icon(Icons.pause, size: 50, color: Colors.green[600]),
                      onPressed: _uploadTask.pause,
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(progressPercent * 100).toStringAsFixed(2)} % ',
                        style:
                            TextStyle(fontSize: 24, color: Colors.green[600]),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 40.0, right: 40.0, bottom: 80.0),
                    child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 30.0,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.green[600]),
                        backgroundColor: Color(0xfffce2e1)),
                  ),
                ]);
          });
    } else {
      return Padding(
        padding: EdgeInsets.only(left: 50.0, right: 50.0, bottom: 40.0),
        child: FlatButton(
            child: Container(
              width: 300.0,
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload, color: Color(0xffe8edf3)),
                    Text('Upload to Firebase',
                        style: TextStyle(color: Color(0xffe8edf3))),
                  ],
                ),
              ),
            ),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 150,
                    color: Colors.green[600],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('Are You Sure Want To Proceed ?',
                              style: TextStyle(
                                  color: Color(0xffe8edf3),
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FlatButton(
                                  color: Color(0xffe8edf3),
                                  child: Text('Upload',
                                      style: TextStyle(
                                          color: Colors.green[600],
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _startUpload();
                                    addurlinfirebase();
                                  }),
                              SizedBox(width: 50.0),
                              FlatButton(
                                color: Color(0xffe8edf3),
                                child: Text('Cancel',
                                    style: TextStyle(
                                        color: Colors.green[600],
                                        fontWeight: FontWeight.bold)),
                                onPressed: () => Navigator.pop(context),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
      );
    }
  }
}
