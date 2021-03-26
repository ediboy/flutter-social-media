import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  // collection reference
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('posts');
}
