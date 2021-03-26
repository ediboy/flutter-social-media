import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_social_media/models/author_model.dart';

class PostModel {
  final String id;
  final String content;
  final AuthorModel author;
  final List attachments;

  PostModel({this.id, this.content, this.author, this.attachments});

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return PostModel(
      id: doc.id,
      content: data['content'] ?? '',
      author: AuthorModel.fromMap(data['author']),
      attachments: data['attachments'] ?? [],
    );
  }
}
