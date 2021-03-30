import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_media/helpers/post_helper.dart';
import 'package:flutter_social_media/models/post_model.dart';
import 'package:flutter_social_media/models/user_model.dart';
import 'package:flutter_social_media/pages/shared/image_slider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

    if (_posts == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
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
                  return _PostItem(post: _posts[index]);
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

class _PostItem extends StatefulWidget {
  final PostModel post;

  _PostItem({this.post});

  @override
  __PostItemState createState() => __PostItemState();
}

class __PostItemState extends State<_PostItem> {
  int _maxLine = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // author
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(widget.post.author.image),
            ),
            title: Text(widget.post.author.name),
            subtitle: Text(widget.post.date.toString()),
          ),

          // attachments
          if (widget.post.attachments.isNotEmpty) ...[
            _Attachments(attachments: widget.post.attachments),
          ],

          // likes

          // comments

          // post
          if (widget.post.content.isNotEmpty) ...[
            Container(
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
            ),
          ]
        ],
      ),
    );
  }
}

// handle attachments
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
