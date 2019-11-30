import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ecommerce/utils/constants.dart';

class LoginGooglePage extends StatefulWidget {
  @override
  LoginPageGoogleState createState() => LoginPageGoogleState();
}

class LoginPageGoogleState extends State<LoginGooglePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Google Login'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                  onPressed: () => googleSignIn()
                      .then((FirebaseUser user) => evaluateGoogleSignIn(user))
                      .catchError((e) => print(e)),
                  padding: EdgeInsets.only(top: 3.0, bottom: 3.0, left: 3.0),
                  color: const Color(0xFFFFFFFF),
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Image.asset(
                        'asset/google_button.jpg',
                        height: 40.0,
                      ),
                      new Container(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new Text(
                            "Sign in with Google",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> evaluateGoogleSignIn(FirebaseUser user) async {
    bool isNewUser = await existUser(user.email);

    if (isNewUser) {
      registerUser(user);
    } else {
      loginUser(user);
    }
  }

  void loginUser(FirebaseUser user) async {
    http.Response response = await http.post('${API_URL}auth/local',
        body: {"identifier": user.email, "password": user.email});
     evaluateAuthResponse(response);
  }

  void registerUser(FirebaseUser user) async {
    http.Response response = await http.post('${API_URL}auth/local/register',
        body: {
          "username": user.email,
          "email": user.email,
          "password": user.email
        });

        evaluateAuthResponse(response);
    
  }

  void evaluateAuthResponse(dynamic response){

final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      storeUserData(responseData);
      showSuccessSnack();
      redirectUser();
      print(responseData);
    } else {
      final String errorMsg = responseData['message'];
      showErrorSnack(errorMsg);
    }

  }


  void storeUserData(responseData) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> user = responseData['user'];
    user.putIfAbsent('jwt', () => responseData['jwt']);
    prefs.setString('user', json.encode(user));
  }

  void redirectUser() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  void showSuccessSnack() {
    final snackbar = SnackBar(
        content: Text('User successfully logged in!',
            style: TextStyle(color: Colors.green)));
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void showErrorSnack(String errorMsg) {
    final snackbar =
        SnackBar(content: Text(errorMsg, style: TextStyle(color: Colors.red)));
    _scaffoldKey.currentState.showSnackBar(snackbar);
    throw Exception('Error logging in: $errorMsg');
  }
}
