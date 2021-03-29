import 'package:flutter/material.dart';
import 'package:flutter_social_media/models/user_model.dart';
import 'package:flutter_social_media/services/auth_service.dart';
import 'package:provider/provider.dart';

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
    final _user = context.watch<UserModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Wall'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () async => AuthService().signOut(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box),
            onPressed: () =>
                Navigator.pushNamed(context, '/create-post', arguments: _user),
          )
        ],
      ),
      body: SafeArea(
        child: Text('content here'),
      ),
    );
  }
}
