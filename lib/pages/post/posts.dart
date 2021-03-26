import 'package:flutter/material.dart';
import 'package:flutter_social_media/models/user_model.dart';
import 'package:flutter_social_media/services/auth_service.dart';

class Posts extends StatefulWidget {
  final UserModel user;
  final UserModel currentUser;

  Posts({this.user, this.currentUser});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wall'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () async => AuthService().signOut(),
        ),
      ),
      body: SafeArea(
        child: Text('content here'),
      ),
    );
  }
}
