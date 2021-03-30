import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_social_media/helpers/create_post_helper.dart';
import 'package:flutter_social_media/models/post_model.dart';
import 'package:flutter_social_media/services/post_service.dart';
import 'package:provider/provider.dart';

class EditPost extends StatefulWidget {
  final PostModel post;

  EditPost({this.post});

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CreatePostHelper>(
            create: (_) => CreatePostHelper()),
        Provider<PostModel>(create: (_) => widget.post),
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
  PostModel _post;
  @override
  void initState() {
    CreatePostHelper _createPostHelper = context.read<CreatePostHelper>();
    _post = context.read<PostModel>();

    _createPostHelper.setCurrentData(_post);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CreatePostHelper _createPostHelper = context.watch<CreatePostHelper>();

    _createPostHelper.context = context;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
        actions: [
          TextButton(
            onPressed: () async {
              // check if text or image is not empty
              if (_createPostHelper.postController.text.isNotEmpty ||
                  _createPostHelper.attachments.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: Center(
                      child: CircularProgressIndicator(),
                    ),
                    backgroundColor: Colors.white.withOpacity(0),
                  ),
                  barrierDismissible: false,
                );

                dynamic result = await PostService().editPost(
                  _post,
                  _createPostHelper.postController.text,
                  _createPostHelper.attachments,
                  _createPostHelper.currentAttachments,
                  _createPostHelper.removedAttachments,
                );

                Navigator.pop(context);

                if (result != null) {
                  setState(() {
                    _createPostHelper.postController.text = '';
                    _createPostHelper.attachments = [];
                    _createPostHelper.currentAttachments = [];
                    _createPostHelper.removedAttachments = [];
                  });

                  Navigator.pop(context, result);
                }
              }
            },
            child: Text(
              'Save',
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
              controller: _createPostHelper.postController ?? null,
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
              itemCount: _createPostHelper.currentAttachments.length,
              itemBuilder: (context, index) {
                return Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.network(
                          _createPostHelper.currentAttachments[index],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            setState(() {
                              _createPostHelper.currentAttachments
                                  .removeAt(index);
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
            if (_createPostHelper.attachments.length > 0) ...[
              SizedBox(height: 20),
              Text(
                'New Images',
                style: Theme.of(context).textTheme.subtitle2,
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
                itemCount: _createPostHelper.attachments.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.memory(
                            _createPostHelper.attachments[index].bytes,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                _createPostHelper.removedAttachments
                                    .add(_createPostHelper.attachments[index]);
                                _createPostHelper.attachments.removeAt(index);
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
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CreatePostHelper _createPostHelper = context.watch<CreatePostHelper>();

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
                _createPostHelper.setAttachment(result);
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
