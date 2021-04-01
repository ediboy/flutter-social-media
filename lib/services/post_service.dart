import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_social_media/models/post_model.dart';
import 'package:flutter_social_media/models/user_model.dart';

class PostService {
  final String postId;

  PostService({this.postId});

  // collection reference
  final CollectionReference _postCollection =
      FirebaseFirestore.instance.collection('posts');

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // create post
  Future createPost(
      String content, List<PlatformFile> attachments, UserModel user) async {
    try {
      WriteBatch _batch = FirebaseFirestore.instance.batch();
      DocumentReference _postDocument = _postCollection.doc();

      // set post content
      _batch.set(_postDocument, {
        'content': content,
        'created_at': FieldValue.serverTimestamp(),
      });

      // handle attachments
      if (attachments.isNotEmpty) {
        dynamic _result = await uploadAttachments(attachments, _postDocument);

        if (_result == null) {
          throw 'Error uploading attachments';
        }

        _batch.update(
            _postCollection.doc(_postDocument.id), {'attachments': _result});
      }

      _batch.update(_postDocument, {
        'user': user.toMap(),
      });

      await _batch.commit().then((value) => true);
      return _postDocument;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // edit post
  Future editPost(
      PostModel post,
      String content,
      List<PlatformFile> attachments,
      List currentAttachments,
      List removedAttachments) async {
    try {
      WriteBatch _batch = FirebaseFirestore.instance.batch();
      DocumentReference _postDocument = _postCollection.doc(post.id);

      // update post content
      _batch.update(_postDocument, {
        'content': content,
      });

      // if attachment has been removed
      if (removedAttachments.isNotEmpty) {
        removeAttachments(removedAttachments);
      }

      // handle attachments
      if (attachments.isNotEmpty) {
        dynamic _result = await uploadAttachments(attachments, _postDocument);

        if (_result == null) {
          throw 'Error uploading attachments';
        }

        List _attachments = currentAttachments;

        _attachments.addAll(_result);

        _batch.update(_postCollection.doc(_postDocument.id),
            {'attachments': _attachments});
      } else {
        _batch.update(_postCollection.doc(_postDocument.id),
            {'attachments': currentAttachments});
      }

      await _batch.commit().then((value) => true);

      return await getPost(_postDocument.id);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // upload post atttachments
  Future uploadAttachments(
      List<PlatformFile> attachments, DocumentReference postDocument) async {
    try {
      List<String> _urls = [];

      for (var attachment in attachments) {
        // upload attachment to storage
        TaskSnapshot _result = await _storage
            .ref('posts/${postDocument.id}/${attachment.name}')
            .putData(attachment.bytes);

        if (_result != null) {
          String _path =
              await _storage.ref(_result.ref.fullPath).getDownloadURL();

          _urls.add(_path);
        }
      }

      return _urls;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // remove post atttachments
  Future removeAttachments(List attachments) async {
    try {
      for (var attachment in attachments) {
        // delete attachment from storage
        _storage.refFromURL(attachment).delete();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // get post
  Future<DocumentSnapshot> getPost(String postId) async {
    try {
      return await _postCollection.doc(postId).get();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // get posts
  Future<QuerySnapshot> getPosts(
      int limit, DocumentSnapshot lastDocument) async {
    try {
      Query query =
          _postCollection.limit(limit).orderBy('created_at', descending: true);

      QuerySnapshot posts;

      // if last document was set, start from there
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      posts = await query.get();

      return posts;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // delete post
  Future deletePost(String postId) async {
    try {
      return await _postCollection.doc(postId).delete().then((value) => true);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // stream post
  Stream<PostModel> get post {
    return _postCollection
        .doc(postId)
        .snapshots()
        .map((snap) => PostModel.fromFirestore(snap));
  }
}
