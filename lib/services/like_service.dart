import 'package:cloud_firestore/cloud_firestore.dart';

class LikeService {
  final String postId;
  final String userId;

  // init service
  LikeService({this.postId, this.userId}) {
    _postDocument = _postCollection.doc(postId);
  }

  // collection reference
  final CollectionReference _postCollection =
      FirebaseFirestore.instance.collection('posts');

  // post document reference
  DocumentReference _postDocument;

  // like post
  Future like() async {
    try {
      return await _postDocument.update({
        'liked_users': FieldValue.arrayUnion([userId]),
        'like_count': FieldValue.increment(1),
      }).then((value) => true);
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // unlike post
  Future unlike() async {
    try {
      return await _postDocument.update({
        'liked_users': FieldValue.arrayRemove([userId]),
        'like_count': FieldValue.increment(-1),
      }).then((value) => true);
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
