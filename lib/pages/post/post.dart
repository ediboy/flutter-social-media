import 'package:flutter/material.dart';
import 'package:flutter_social_media/helpers/comment_helper.dart';
import 'package:flutter_social_media/helpers/post_helper.dart';
import 'package:flutter_social_media/models/comment_model.dart';
import 'package:flutter_social_media/models/post_model.dart';
import 'package:flutter_social_media/models/user_model.dart';
import 'package:flutter_social_media/pages/shared/post_item.dart';
import 'package:flutter_social_media/services/comment_service.dart';
import 'package:flutter_social_media/services/post_service.dart';
import 'package:provider/provider.dart';

class Post extends StatefulWidget {
  final String postId;
  final UserModel user;

  Post({this.postId, this.user});

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  CommentHelper _commentHelper = CommentHelper();
  PostHelper _postHelper = PostHelper();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CommentHelper>(create: (_) => _commentHelper),
        Provider<PostHelper>(create: (_) => _postHelper),
        StreamProvider<PostModel>.value(
          value: PostService(postId: widget.postId).post,
          initialData: null,
        ),
        Provider<UserModel>(create: (_) => widget.user),
      ],
      child: _PostContent(),
    );
  }
}

class _PostContent extends StatefulWidget {
  @override
  __PostContentState createState() => __PostContentState();
}

class __PostContentState extends State<_PostContent> {
  @override
  Widget build(BuildContext context) {
    PostModel _post = context.watch<PostModel>();
    UserModel _user = context.watch<UserModel>();
    CommentHelper _commentHelper = context.watch<CommentHelper>();

    if (_post == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    CommentService _commentService = CommentService(postId: _post.id);

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        // color: Theme.of(context).primaryColor.withOpacity(.1),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  PostItem(
                    post: _post,
                    isPostPage: true,
                  ),
                  Divider(),
                  StreamProvider<List<CommentModel>>.value(
                    value: _commentService.comments,
                    initialData: [],
                    child: _Comments(),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              color: Theme.of(context).primaryColor.withOpacity(.1),
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Write something...',
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      if (_commentHelper.commentController.text != '') {
                        dynamic result;
                        if (_commentHelper.selectedCommentId.isEmpty) {
                          result = await _commentService.addComment(
                              _commentHelper.commentController.text, _user);
                        } else {
                          result = await _commentService.updateComment(
                              _commentHelper.commentController.text,
                              _commentHelper.selectedCommentId);
                        }

                        if (result != null) {
                          _commentHelper.commentController.text = '';
                          _commentHelper.selectedCommentId = '';
                        }
                      }
                    },
                  ),
                ),
                maxLines: null,
                controller: _commentHelper.commentController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Comments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<CommentModel> _comments = context.watch<List<CommentModel>>();

    if (_comments == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      reverse: true,
      itemBuilder: (context, index) => _Comment(comment: _comments[index]),
      separatorBuilder: (context, index) => SizedBox(height: 5),
      itemCount: _comments.length,
    );
  }
}

class _Comment extends StatefulWidget {
  final CommentModel comment;

  _Comment({this.comment});

  @override
  __CommentState createState() => __CommentState();
}

class __CommentState extends State<_Comment> {
  String _userId;

  @override
  void initState() {
    _userId = context.read<UserModel>().id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CommentHelper _commentHelper = context.watch<CommentHelper>();
    PostModel _post = context.watch<PostModel>();

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(widget.comment.author.image),
      ),
      title: Text(widget.comment.author.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.comment.content),
          SizedBox(height: 5),
          Text(
            widget.comment.date.toString(),
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
      isThreeLine: true,
      trailing: (_userId == widget.comment.author.id)
          ? PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('edit'),
                  value: 'edit',
                ),
                PopupMenuItem(
                  child: Text('delete'),
                  value: 'delete',
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  _commentHelper.commentController.text =
                      widget.comment.content;
                  _commentHelper.selectedCommentId = widget.comment.id;
                }

                if (value == 'delete') {
                  dynamic _result = await CommentService(postId: _post.id)
                      .deleteComment(widget.comment.id);

                  if (_result != null) {
                    PostHelper().showMessage('Comment deleted');
                  }
                }
              },
            )
          : null,
    );
  }
}
