import 'package:flutter/rendering.dart';

import 'nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'Authentication/login_screen.dart';
import 'Authentication/transition_route_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Chat123.dart';
import 'dart:ui' as ui;

Future<void> main() async {
  RenderErrorBox.backgroundColor = Colors.white;
  RenderErrorBox.textStyle = ui.TextStyle(color: Colors.white);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var status = prefs.getString('email');
  currentUser = status;
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor:
          SystemUiOverlayStyle.dark.systemNavigationBarColor,
    ),
  );
  runApp(MyApp(status: status));
}

class MyApp extends StatelessWidget {
  @override
  MyApp({this.status});
  var status;
  ThemeData theme;
  Widget build(BuildContext context) {
    if (status != null)
      Chat123(currentUser: currentUser.substring(0, currentUser.length - 10));
    return MaterialApp(
        theme: ThemeData(
          // brightness: Brightness.dark,
          primarySwatch: Colors.green,
          accentColor: Colors.white,
          cursorColor: Colors.white,
          // fontFamily: 'SourceSansPro',
          textTheme: TextTheme(
            display2: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 45.0,
              // fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            button: TextStyle(
              // OpenSans is similar to NotoSans but the uppercases look a bit better IMO
              fontFamily: 'OpenSans',
            ),
            caption: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
              color: Colors.deepPurple[300],
            ),
            display4: TextStyle(fontFamily: 'Quicksand'),
            display3: TextStyle(fontFamily: 'Quicksand'),
            display1: TextStyle(fontFamily: 'Quicksand'),
            headline: TextStyle(fontFamily: 'NotoSans'),
            title: TextStyle(fontFamily: 'NotoSans'),
            subhead: TextStyle(fontFamily: 'NotoSans'),
            body2: TextStyle(fontFamily: 'NotoSans'),
            body1: TextStyle(fontFamily: 'NotoSans'),
            subtitle: TextStyle(fontFamily: 'NotoSans'),
            overline: TextStyle(fontFamily: 'NotoSans'),
          ),
        ),
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: status != null ? Nav_Bar() : LoginScreen()));
  }
}
