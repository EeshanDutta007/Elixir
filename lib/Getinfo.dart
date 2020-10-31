import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';

String email;
File _imageFile;
Future<void> currentUserEmail() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  email=prefs.getString('email');
}

final _firestore = Firestore.instance;
class GetInfo extends StatefulWidget {
  @override
  _GetInfoState createState() => _GetInfoState();
}

class _GetInfoState extends State<GetInfo> {
  final messageTextController = TextEditingController();
  String messageText='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
              padding: EdgeInsets.only(top:150),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height:50,
                    width: MediaQuery.of(context).size.width - 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.bottom,
                      controller: messageTextController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: HexColor('#77FF77'),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: HexColor('#77FF77'),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        hintText: ' Enter your text here...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15.0,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      onChanged: (value){
                        messageText = value;
                      },
                      //-------- Password input stored in a String ---------//
                    ),
                  ),
                  SizedBox(height: 20,),
                  RaisedButton(
                    elevation: 8,
                    onPressed: (){
                      if(messageText.length<5){
                        Fluttertoast.showToast(
                            msg: "Minimum 5 Letters Required",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black54,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      else if(messageText!=''){
                        messageTextController.clear();
                        _firestore.collection('blogs').add({
                          'text': messageText,
                          'sender': email,
                          'time': DateTime.now(),
                        });
                        messageText='';
                      }
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      child: Text('Upload Text',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                      child: Text('OR',
                          style: TextStyle(fontSize: 50))
                  ),
                  SizedBox(height: 40,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        onPressed: ()async{
                          //Navigator.of(context).pop();
                          // ignore: deprecated_member_use
                          File selected = await ImagePicker.pickImage(source: ImageSource.camera);
                          setState(() {
                            _imageFile = selected;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ImageCapture(file: _imageFile)));
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          child:Icon(Icons.camera_alt_outlined, size: 50,),
                        ),
                      ),
                      SizedBox(width:30),
                      FlatButton(
                        onPressed: ()async{
                          // ignore: deprecated_member_use
                          //Navigator.of(context).pop();
                          File selected = await ImagePicker.pickImage(source: ImageSource.gallery);
                          setState(() {
                            _imageFile = selected;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ImageCapture(file: _imageFile)));
                        },
                        child: Container(
                          child:Icon(Icons.photo, size: 50,),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30,),
                  Container(
                    child:Text('Choose an Image',style: TextStyle(fontSize: 30),),
                  ),
                ],
              )
          )
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
      backgroundColor: HexColor('#373A36'),
      appBar: AppBar(
        title: Center(child: Text('Selected Image')),
        backgroundColor: HexColor('#77FF77'),
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
    _firestore.collection('blogs').add({
      'text': '$url.jpeg',
      'sender': " ",
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
                            color: HexColor('#77FF77'), height: 2, fontSize: 30)),
                  if (_uploadTask.isPaused)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: FlatButton(
                        child: Icon(Icons.play_arrow,
                            size: 50, color: HexColor('#77FF77')),
                        onPressed: _uploadTask.resume,
                      ),
                    ),
                  if (_uploadTask.isInProgress)
                    FlatButton(
                      child:
                      Icon(Icons.pause, size: 50, color: HexColor('#77FF77')),
                      onPressed: _uploadTask.pause,
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(progressPercent * 100).toStringAsFixed(2)} % ',
                        style:
                        TextStyle(fontSize: 24, color: HexColor('#77FF77')),
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
                        AlwaysStoppedAnimation<Color>(Colors.green[700]),
                        backgroundColor: Colors.green[600]),
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
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload, color: Color(0xffe8edf3)),
                    Text('Upload',
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
                    color: Colors.green[700],
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
                                  child: const Text('Upload',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _startUpload();
                                    addurlinfirebase();
                                  }),
                              SizedBox(width: 50.0),
                              FlatButton(
                                color: Color(0xffe8edf3),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: Colors.black,
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



