import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_social_media/models/comment_model.dart';
import 'package:flutter_social_media/models/user_model.dart';

class CommentService {
  final String postId;

  // init service
  CommentService({this.postId}) {
    _postDocument = _postCollection.doc(postId);
    _commentCollection = _postDocument.collection('comments');
  }

  // collection reference
  final CollectionReference _postCollection =
      FirebaseFirestore.instance.collection('posts');

  CollectionReference _commentCollection;

  // post document reference
  DocumentReference _postDocument;

  // add comment
  Future addComment(String comment, UserModel user) async {
    try {
      WriteBatch _batch = FirebaseFirestore.instance.batch();
      DocumentReference _commentDocument = _commentCollection.doc();

      _batch.set(_commentDocument, {
        'user': user.toMap(),
        'content': comment,
        'created_at': FieldValue.serverTimestamp(),
      });

      _batch.update(_postDocument, {
        'comment_count': FieldValue.increment(1),
      });

      return await _batch.commit().then((value) => true);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // edit comment
  Future updateComment(String comment, String commentId) async {
    try {
      return await _commentCollection
          .doc(commentId)
          .update({'content': comment});
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // map comment
  List<CommentModel> _mapComment(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((snap) => CommentModel.fromFirestore(snap))
        .toList();
  }

  // stream comment
  // not idea for production but this will demonstrate real time comments
  Stream<List<CommentModel>> get comments {
    return _commentCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(_mapComment);
  }

  // delete comment
  Future deleteComment(String commentId) async {
    try {
      WriteBatch _batch = FirebaseFirestore.instance.batch();
      DocumentReference _commentDocument = _commentCollection.doc(commentId);

      _batch.update(_postDocument, {
        'comment_count': FieldValue.increment(-1),
      });

      _batch.delete(_commentDocument);

      return await _batch.commit().then((value) => true);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
