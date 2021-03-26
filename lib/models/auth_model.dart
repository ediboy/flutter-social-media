import 'package:firebase_auth/firebase_auth.dart';

class AuthModel {
  final String uid;
  final String email;

  AuthModel({this.uid, this.email});

  factory AuthModel.fromMap(User user) {
    return AuthModel(
      uid: user.uid,
      email: user.email,
    );
  }
}
