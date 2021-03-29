import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_social_media/models/user_model.dart';

class PostService {
  // collection reference
  final CollectionReference postCollection =
      FirebaseFirestore.instance.collection('posts');

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // create post
  Future createPost(
      String post, List<PlatformFile> attachments, UserModel user) async {
    try {
      WriteBatch _batch = FirebaseFirestore.instance.batch();
      DocumentReference _postDocument = postCollection.doc();

      // if post is not empty
      _batch.set(_postDocument, {
        'content': post,
        'created_at': FieldValue.serverTimestamp(),
      });

      // handle attachments
      if (attachments.isNotEmpty) {
        dynamic _result = await uploadAttachments(attachments, _postDocument);

        if (_result == null) {
          throw 'Error uploading attachments';
        }

        _batch.update(
            postCollection.doc(_postDocument.id), {'attachments': _result});
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

  // get posts
  Future<QuerySnapshot> getPosts(
      int limit, DocumentSnapshot lastDocument) async {
    try {
      Query query =
          postCollection.limit(limit).orderBy('created_at', descending: true);

      QuerySnapshot posts;

      // if last document was set, start from there
      if (lastDocument != null) {
        posts = await query.startAfterDocument(lastDocument).get();
      } else {
        posts = await query.get();
      }

      return posts;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
