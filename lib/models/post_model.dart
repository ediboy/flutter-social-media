import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_social_media/helpers/post_helper.dart';
import 'package:flutter_social_media/models/user_model.dart';

class PostModel {
  final String id;
  final String content;
  final UserModel author;
  final List attachments;
  final String date;
  int likeCount;
  int commentCount;
  List likedUsers;

  PostModel({
    this.id,
    this.content,
    this.author,
    this.attachments,
    this.date,
    this.likeCount,
    this.commentCount,
    this.likedUsers,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();

    return PostModel(
      id: doc.id,
      content: data['content'] ?? '',
      author: UserModel.fromMap(data['user']),
      attachments: data['attachments'] ?? [],
      date: PostHelper().converDate(data['created_at'].toDate()),
      likeCount: data['like_count'] ?? 0,
      commentCount: data['comment_count'] ?? 0,
      likedUsers: data['liked_users'] ?? [],
    );
  }
}
