import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_social_media/helpers/post_helper.dart';
import 'package:flutter_social_media/models/user_model.dart';
import 'package:flutter_social_media/services/post_service.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatefulWidget {
  final UserModel user;

  CreatePost({this.user});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PostHelper>(create: (_) => PostHelper()),
        Provider<UserModel>(create: (_) => widget.user),
      ],
      child: _PostForm(),
    );
  }
}

class _PostForm extends StatefulWidget {
  @override
  __PostFormState createState() => __PostFormState();
}

class __PostFormState extends State<_PostForm> {
  @override
  Widget build(BuildContext context) {
    PostHelper _postHelper = context.watch<PostHelper>();
    UserModel _user = context.watch<UserModel>();

    _postHelper.context = context;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
        actions: [
          TextButton(
            onPressed: () async {
              // check if text or image is not empty
              if (_postHelper.postController.text.isNotEmpty ||
                  _postHelper.attachments.isNotEmpty) {
                dynamic result = await PostService().createPost(
                    _postHelper.postController.text,
                    _postHelper.attachments,
                    _user);

                if (result != null) {
                  setState(() {
                    _postHelper.postController.text = '';
                    _postHelper.attachments = [];
                  });

                  Navigator.pop(context);
                }
              }
            },
            child: Text(
              'Post',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(15),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Write something...',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              maxLines: 6,
              controller: _postHelper.postController ?? null,
            ),
            SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: _postHelper.attachments.length,
              itemBuilder: (context, index) {
                return Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.memory(
                          _postHelper.attachments[index].bytes,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            setState(() {
                              _postHelper.attachments.removeAt(index);
                            });
                          },
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PostHelper _postHelper = context.watch<PostHelper>();

    return Container(
      color: Theme.of(context).primaryColor.withOpacity(.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.photo_library,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () async {
              FilePickerResult result = await FilePicker.platform.pickFiles(
                allowMultiple: true,
                type: FileType.custom,
                allowedExtensions: ['jpg', 'jpeg', 'png'],
              );
              if (result != null) {
                _postHelper.setAttachment(result);
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.camera_alt,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
