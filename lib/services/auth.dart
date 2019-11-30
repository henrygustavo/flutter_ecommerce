import 'dart:async';
import 'dart:convert';
import 'package:flutter_ecommerce/utils/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future <FirebaseUser> googleSignIn() async {  
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

Future<bool> existUser(String email) async {

  http.Response response = await http.get('${API_URL}users');
  final List<dynamic> responseData = json.decode(response.body);
  var user = responseData.firstWhere((user) => user["email"] == email, orElse: () => null);

  return user == null;

}