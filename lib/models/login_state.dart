import 'package:firebase_auth/firebase_auth.dart';

class LoginStateModel {
  bool isLoading;
  FirebaseUser user;
  LoginStateModel({  
    this.isLoading = false,
    this.user, 
  });
}