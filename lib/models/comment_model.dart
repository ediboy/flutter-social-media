import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_social_media/helpers/post_helper.dart';
import 'package:flutter_social_media/models/user_model.dart';

class CommentModel {
  final String id;
  final String content;
  final UserModel author;
  final String date;

  CommentModel({
    this.id,
    this.content,
    this.author,
    this.date,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();

    return CommentModel(
      id: doc.id,
      content: data['content'] ?? '',
      author: UserModel.fromMap(data['user']),
      date: (data['created_at'] != null)
          ? PostHelper().converDate(data['created_at'].toDate())
          : '',
    );
  }
}
