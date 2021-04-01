import 'package:flutter/material.dart';
import 'package:flutter_social_media/models/user_model.dart';
import 'package:flutter_social_media/services/like_service.dart';
import 'package:provider/provider.dart';

class Likes extends StatelessWidget {
  final List users;

  Likes({this.users});

  @override
  Widget build(BuildContext context) {
    return FutureProvider<List<UserModel>>.value(
      value: LikeService().getLikedUsers(users),
      initialData: [],
      child: _LikeList(),
    );
  }
}

class _LikeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<UserModel> _users = context.watch<List<UserModel>>();

    if (_users == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Likes'),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(_users[index].image),
            ),
            title: Text(_users[index].name),
          ),
          separatorBuilder: (context, index) => Divider(),
          itemCount: _users.length,
        ),
      ),
    );
  }
}
