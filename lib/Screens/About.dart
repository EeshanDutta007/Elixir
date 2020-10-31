import 'package:ctrl_alt_elite/Screens/Aboutdevs.dart';
import 'package:ctrl_alt_elite/database.dart';
import 'package:ctrl_alt_elite/nav_bar.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ctrl_alt_elite/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

String email;
String origEmail;

class AboutPage extends StatefulWidget {
  String currentUser;
  AboutPage({this.currentUser});
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String image;
  final FirebaseAuth auth = FirebaseAuth.instance;
  // void setData()async{
  //   final prefs = await SharedPreferences.getInstance();
  //   email = prefs.getString('email');
  //   String result = email.substring(0, email.indexOf('@'));
  //   email = result;
  // }
  void initState() {
    origEmail = currentUser;
    email = currentUser.substring(0, currentUser.indexOf('@'));
    image = _getImage(context).toString();
    return;
  }

  File profilePic;

  Future getImage(ImageSource source) async {
    var tempImage = await ImagePicker.pickImage(source: source);
    var croppedImage = await ImageCropper.cropImage(
        sourcePath: tempImage.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
    setState(() {
      profilePic = tempImage;
    });
    await DatabaseService().updateUserPic(profilePic);
    uploadImage(context, profilePic);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: HexColor('#373A36'),
      child: Stack(
        children: [
          ProfileContainer(),
          Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width / 2 + 20, 200, 0, 0),
            child: ButtonTheme(
              minWidth: 20,
              height: 40,
              child: RaisedButton(
                onPressed: () async {
                  await getImage(ImageSource.gallery);
                  initState() {
                    super.initState();
                    new ProfileContainer();
                  }
                },
                child: Icon(Icons.camera_alt_outlined),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                30, MediaQuery.of(context).size.height / 2 - 50, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Text(
                    email == null ? 'null' : email,
                    style: TextStyle(
                      color: HexColor('#77FF77'),
                      fontSize: 40,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0,
                MediaQuery.of(context).size.height - 150, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                    color: HexColor('#77FF77'),
                    child: Container(
                        height: 30,
                        width: 50,
                        child: Center(
                            child: Text('Logout', style: TextStyle(fontSize: 15)))),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.remove('email');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyApp(status: null)),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )
                ),
                SizedBox(width: 30,),
                RaisedButton(
                    color: HexColor('#77FF77'),
                    child: Container(
                        height: 30,
                        width: 50,
                        child: Center(
                            child: Text('About', style: TextStyle(fontSize: 15)))),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutDev())
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  selectImageDialog(BuildContext context) {
    // Create button
    Widget CameraButton = FlatButton(
      child: Row(
        children: [
          Icon(Icons.camera_alt_outlined),
          Text('Camera'),
        ],
      ),
      onPressed: () async {
        await getImage(ImageSource.camera);
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => new Nav_Bar()),
            (route) => false,
          );
        });
      },
    );

    Widget GalleryButton = FlatButton(
      child: Row(
        children: [
          Icon(Icons.image),
          Text('Gallery'),
        ],
      ),
      onPressed: () async {
        await getImage(ImageSource.gallery);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => new Nav_Bar()),
          (route) => false,
        );
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Select Image from"),
      actions: [
        CameraButton,
        GalleryButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class ProfileContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width / 2 - 75, 100, 0, 0),
        child: FutureBuilder(
            future: _getImage(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.grey[600],
                    child: Text('Error'),
                  );
                } else {
                  return CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.grey[600],
                    backgroundImage: NetworkImage(
                      snapshot.data.toString(),
                    ),
                  );
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.grey[600],
                  child: Text('Loading...'),
                );
              }
              return CircleAvatar(
                radius: 75,
                backgroundColor: Colors.grey[600],
                child: Text(''),
              );
            }));
  }
}

Future<dynamic> uploadImage(BuildContext context, File profilePic) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User user = auth.currentUser;
  final uid = user.uid;
  FirebaseStorage storage = FirebaseStorage(
    storageBucket: "gs://ctrl-alt-elite-bd79d.appspot.com/",
  );
  var firebaseStorageRef = storage.ref().child('profilePics/${uid}.jpg');
  var uploadtask = firebaseStorageRef.putFile(profilePic);
  var completedTask = await uploadtask.onComplete;
  String downloadUrl = await completedTask.ref.getDownloadURL();
}

Future<String> _getImage(BuildContext context) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User user = auth.currentUser;
  final uid = user.uid;
  String url;
  Image m;
  await loadImage(context, uid).then((downloadUrl) {
    m = Image.network(downloadUrl.toString(), fit: BoxFit.scaleDown);
    print(downloadUrl.toString());
    url = downloadUrl.toString();
  });
  return url;
}

Future<dynamic> loadImage(BuildContext context, String image) async {
  return await FirebaseStorage.instance
      .ref()
      .child('profilePics/${image}.jpg')
      .getDownloadURL();
}

showAlertDialog(BuildContext context, String str) {
  // Create button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Error"),
    content: Text(str),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
