import 'dart:io';
import 'package:Elixir/Authentication/custom_route.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../database.dart';
import '../One_on_One_chat/chatroom.dart';
import '../One_on_One_chat/database1.dart';
//import 'custom_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Elixir/nav_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../One_on_One_chat/database.dart';
import '../One_on_One_chat/database1.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';
  String email = '';
  String password = '';
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  Future<String> _loginUser(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      /*if (!mockUsers.containsKey(data.name)) {
        return 'Username not exists';
      }
      if (mockUsers[data.name] != data.password) {
        return 'Password does not match';
      }*/
      return null;
    });
  }

  Future<void> IsEmailVerified(BuildContext context) async {
    FirebaseUser User = await FirebaseAuth.instance.currentUser;
    if (User.emailVerified) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Nav_Bar()),
      );
    } else {
      showAlertDialog(context, 'Please Confirm your email id');
    }
  }

  void sendVerificationEmail() async {
    var User = await FirebaseAuth.instance.currentUser;
    try {
      await User.sendEmailVerification();
      Fluttertoast.showToast(
          msg: 'Email Verification send, Please verify your email');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Some Error Occurred');
    }
  }

  Future<String> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final inputBorder = BorderRadius.vertical(
      bottom: Radius.circular(10.0),
      top: Radius.circular(20.0),
    );

    return FlutterLogin(
      logo: 'assets/images/icon.png',
      title: 'Elixir',
      messages: LoginMessages(
        forgotPasswordButton: ' ',
      ),
      emailValidator: (value) {
        if (!value.contains('@') || !value.endsWith('.com')) {
          return "Email must contain '@' and end with '.com'";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) async {
        print('Login info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        email = loginData.name;
        password = loginData.password;
        try {
          final user = await _auth.signInWithEmailAndPassword(
              email: email, password: password);
          if (user != null) {
            final prefs = await SharedPreferences.getInstance();
            prefs.remove('email');
            prefs.setString('email', email);
            IsEmailVerified(context);
            ChatRoom();
            Navigator.of(context).pushReplacement(FadePageRoute(
              builder: (context) => Nav_Bar(),
            ));
          }
        } catch (e) {
          showAlertDialog(context, 'Invalid email or password');
        }
        return _loginUser(loginData);
      },
      onSignup: (loginData) async {
        print('Signup info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        email = loginData.name;
        password = loginData.password;
        try {
          final newUser = await _auth.createUserWithEmailAndPassword(
              email: email, password: password);
          await DatabaseService()
              .updateUserData(email.substring(0, email.length - 10));
          sendVerificationEmail();
          if (newUser != null) {
            Map<String, String> userDataMap = {
              "userName":
                  loginData.name.substring(0, loginData.name.length - 10),
              "userEmail": loginData.name,
            };
            DatabaseMethods databaseMethods = new DatabaseMethods();
            databaseMethods.addUserInfo(userDataMap);
            Fluttertoast.showToast(
                msg: "Registration successful",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.of(context).pushReplacement(FadePageRoute(
              builder: (context) => LoginScreen(),
            ));
          }
        } catch (e) {
          showAlertDialog(context, 'Username already registered');
        }
        return _loginUser(loginData);
      },
      onRecoverPassword: (name) {
        print('Recover password info');
        print('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
      showDebugButtons: true,
    );
  }
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
