import 'package:flutter/material.dart';
import 'package:flutter_social_media/helpers/post_helper.dart';
import 'package:flutter_social_media/models/post_model.dart';
import 'package:flutter_social_media/models/user_model.dart';
import 'package:flutter_social_media/pages/shared/post_item.dart';
import 'package:flutter_social_media/services/auth_service.dart';
import 'package:provider/provider.dart';

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  PostHelper _postHelper = PostHelper();

  @override
  void initState() {
    // load inital post records
    _postHelper.loadPosts();

    // check if we need to paginate
    _postHelper.scrollController.addListener(() {
      if (_postHelper.scrollController.position.maxScrollExtent ==
          _postHelper.scrollController.offset) {
        _postHelper.loadMore();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PostHelper>(create: (_) => _postHelper),
        StreamProvider<List<PostModel>>.value(
          value: _postHelper.stream,
          initialData: [],
        ),
      ],
      child: _PostList(),
    );
  }
}

class _PostList extends StatefulWidget {
  @override
  __PostListState createState() => __PostListState();
}

class __PostListState extends State<_PostList> {
  PostHelper _postHelper;

  @override
  void initState() {
    _postHelper = context.read<PostHelper>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<PostModel> _posts = context.watch<List<PostModel>>();
    final _user = context.watch<UserModel>();
    _postHelper.context = context;

    if (_posts == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () async => AuthService().signOut()),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box),
            onPressed: () =>
                Navigator.pushNamed(context, '/create-post', arguments: _user)
                    .then((value) => _postHelper.refresh()),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _postHelper.refresh,
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: ListView.separated(
              physics: AlwaysScrollableScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(height: 10),
              itemCount: _posts.length + 1,
              itemBuilder: (context, index) {
                if (index < _posts.length) {
                  return PostItem(post: _posts[index]);
                } else if (_postHelper.noMoreData) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Center(child: Text('That\'s all folks')),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
              controller: _postHelper.scrollController,
            ),
          ),
        ),
      ),
    );
  }
}
