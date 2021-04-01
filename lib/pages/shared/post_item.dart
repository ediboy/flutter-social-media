import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_media/arguments/post_arguments.dart';
import 'package:flutter_social_media/helpers/post_helper.dart';
import 'package:flutter_social_media/models/post_model.dart';
import 'package:flutter_social_media/models/user_model.dart';
import 'package:flutter_social_media/pages/shared/image_slider.dart';
import 'package:flutter_social_media/services/like_service.dart';
import 'package:flutter_social_media/services/post_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class PostItem extends StatefulWidget {
  final PostModel post;
  final bool isPostPage;

  PostItem({this.post, this.isPostPage: false});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  PostHelper _postHelper;
  UserModel _user;

  @override
  void initState() {
    _postHelper = context.read<PostHelper>();
    _user = context.read<UserModel>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isPostPage
          ? null
          : Theme.of(context).primaryColor.withOpacity(.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // author
          _Author(
            post: widget.post,
            postHelper: _postHelper,
            userId: _user.id,
          ),

          // attachments
          if (widget.post.attachments.isNotEmpty) ...[
            _Attachments(attachments: widget.post.attachments),
          ],

          // post
          if (widget.post.content.isNotEmpty) ...[
            _Post(post: widget.post),
          ],

          // likes & comment
          Row(
            children: [
              _Like(
                post: widget.post,
                userId: _user.id,
                postHelper: _postHelper,
              ),
              SizedBox(width: 10),
              _Comment(
                post: widget.post,
                user: _user,
                postHelper: _postHelper,
                isPostPage: widget.isPostPage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// author widget
class _Author extends StatelessWidget {
  final PostModel post;
  final PostHelper postHelper;
  final String userId;

  _Author({this.post, this.postHelper, this.userId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(post.author.image),
      ),
      title: Text(post.author.name),
      subtitle: Text(post.date.toString()),
      trailing: (userId == post.author.id)
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
                  final _post = await Navigator.pushNamed(context, '/edit-post',
                      arguments: post);

                  postHelper.updatePostContent(_post);
                  postHelper.showMessage('Post updated');
                }

                if (value == 'delete') {
                  dynamic _result = await PostService().deletePost(post.id);

                  if (_result != null) {
                    postHelper.removePostContent(post.id);
                    postHelper.showMessage('Post deleted');
                  }
                }
              },
            )
          : null,
    );
  }
}

// attachments widget
class _Attachments extends StatelessWidget {
  final List attachments;

  _Attachments({this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.length == 1) {
      return _SingleAttachment(attachments: attachments);
    }

    if (attachments.length == 2) {
      return _DoubleAttachment(attachments: attachments);
    }

    if (attachments.length == 3) {
      return _TripleAttachment(attachments: attachments);
    }

    if (attachments.length == 4) {
      return _QuadAttachment(attachments: attachments);
    }

    return _MoreAttachment(attachments: attachments);
  }
}

// single attachment
class _SingleAttachment extends StatelessWidget {
  final List attachments;

  _SingleAttachment({this.attachments});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => ImageSlider(
          images: attachments,
          selectedIndex: 1,
        ),
      ),
      child: Container(
        color: Colors.black,
        constraints: BoxConstraints(maxHeight: 650),
        width: double.infinity,
        child: Image.network(
          attachments[0],
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// 2 attachment
class _DoubleAttachment extends StatelessWidget {
  final List attachments;

  _DoubleAttachment({this.attachments});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: attachments.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => ImageSlider(
              images: attachments,
              selectedIndex: index,
            ),
          ),
          child: Container(
            child: Image.network(
              attachments[index],
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

// 3 attachment
class _TripleAttachment extends StatelessWidget {
  final List attachments;

  _TripleAttachment({this.attachments});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: attachments.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => ImageSlider(
              images: attachments,
              selectedIndex: index,
            ),
          ),
          child: Container(
            child: Image.network(
              attachments[index],
              fit: BoxFit.cover,
            ),
          ),
        ),
        staggeredTileBuilder: (int index) =>
            new StaggeredTile.count(1, index.isEven ? 1 : 2),
      ),
    );
  }
}

// 4 attachment
class _QuadAttachment extends StatelessWidget {
  final List attachments;

  _QuadAttachment({this.attachments});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: attachments.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => ImageSlider(
              images: attachments,
              selectedIndex: index,
            ),
          ),
          child: Container(
            child: Image.network(
              attachments[index],
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

// more than 4 attachment
class _MoreAttachment extends StatelessWidget {
  final List attachments;

  _MoreAttachment({this.attachments});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: 4,
          itemBuilder: (context, index) {
            if (index == 3) {
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      attachments[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => ImageSlider(
                        images: attachments,
                        selectedIndex: index,
                      ),
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(.3),
                      child: Center(
                        child: Text(
                          '+${attachments.length - 4}',
                          style: Theme.of(context).textTheme.headline2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => ImageSlider(
                  images: attachments,
                  selectedIndex: index,
                ),
              ),
              child: Container(
                child: Image.network(
                  attachments[index],
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
    );
  }
}

// post widget
class _Post extends StatefulWidget {
  final PostModel post;

  _Post({this.post});

  @override
  __PostState createState() => __PostState();
}

class __PostState extends State<_Post> {
  int _maxLine = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: AutoSizeText(
        widget.post.content,
        maxLines: _maxLine,
        minFontSize: 15,
        overflowReplacement: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _maxLine = null;
                });
              },
              child: Text(
                "read more",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Like extends StatefulWidget {
  final PostModel post;
  final String userId;
  final PostHelper postHelper;

  _Like({this.post, this.userId, this.postHelper});

  @override
  __LikeState createState() => __LikeState();
}

class __LikeState extends State<_Like> {
  @override
  Widget build(BuildContext context) {
    final bool _isPostLiked =
        widget.postHelper.checkUserLiked(widget.post, widget.userId);

    return Row(
      children: [
        if (_isPostLiked) ...[
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            onPressed: () {
              LikeService(postId: widget.post.id, userId: widget.userId)
                  .unlike();

              setState(() {
                widget.post.likeCount -= 1;
                widget.post.likedUsers.remove(widget.userId);
              });
            },
          )
        ] else ...[
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Colors.grey,
            ),
            onPressed: () {
              LikeService(postId: widget.post.id, userId: widget.userId).like();

              setState(() {
                widget.post.likeCount += 1;
                widget.post.likedUsers.add(widget.userId);
              });
            },
          )
        ],
        if (widget.post.likeCount != 0) ...[
          InkWell(
            onTap: () {},
            child: Text(widget.post.likeCount.toString()),
          ),
        ],
      ],
    );
  }
}

class _Comment extends StatefulWidget {
  final PostModel post;
  final UserModel user;
  final PostHelper postHelper;
  final bool isPostPage;

  _Comment({this.post, this.user, this.postHelper, this.isPostPage});

  @override
  __CommentState createState() => __CommentState();
}

class __CommentState extends State<_Comment> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(
        icon: Icon(
          Icons.chat_bubble_outline,
          color: Colors.grey,
        ),
        onPressed: () => {
          if (!widget.isPostPage)
            {
              Navigator.pushNamed(context, '/post',
                  arguments:
                      PostArguments(postId: widget.post.id, user: widget.user))
            }
        },
      ),
      if (widget.post.commentCount != 0) ...[
        InkWell(
          onTap: () {},
          child: Text(widget.post.commentCount.toString()),
        ),
      ],
    ]);
  }
}
