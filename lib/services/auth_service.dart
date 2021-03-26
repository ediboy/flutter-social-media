import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_social_media/models/auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // create user obj based on Firebase User
  AuthModel _userFromFirebaseUser(User user) {
    return user != null ? AuthModel.fromMap(user) : null;
  }

  // auth change user stream
  Stream<AuthModel> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // login with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = userCredential.user;

      // set user to online
      await userCollection.doc(user.uid).update({'online': true});

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // logout
  Future signOut() async {
    try {
      // set user to online
      await userCollection.doc(_auth.currentUser.uid).update({'online': false});

      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
