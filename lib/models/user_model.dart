import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String image;
  final bool online;

  UserModel({this.id, this.name, this.image, this.online});

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      online: data['online'] ?? false,
    );
  }
}
