import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginGooglePage extends StatefulWidget {
  @override
  LoginPageGoogleState createState() => LoginPageGoogleState();
}

class LoginPageGoogleState extends State<LoginGooglePage> {
final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future < FirebaseUser > googleSignin() async {  
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
  print("signed in " + user.displayName);
  return user;
}  


  @override
  Widget build(BuildContext context) {

       return Scaffold(
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
                  onPressed: () => googleSignin()
                                  .then((FirebaseUser user) => print(user))
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
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

}
