import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_social_media/models/user_model.dart';

class UserService {
  final String id;
  final String email;

  UserService({this.id, this.email});

  // collection reference
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // stream user
  Stream<UserModel> get user {
    return _userCollection
        .doc(id)
        .snapshots()
        .map((snap) => UserModel.fromFirestore(snap));
  }
}
