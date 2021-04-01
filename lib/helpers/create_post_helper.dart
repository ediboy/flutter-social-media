import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_media/models/post_model.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostHelper extends ChangeNotifier {
  List<PlatformFile> attachments = [];
  List currentAttachments = [];
  List removedAttachments = [];
  BuildContext context;
  final TextEditingController postController = new TextEditingController();
  File cameraImage;
  final picker = ImagePicker();

  // populate attachments
  void setAttachment(FilePickerResult result) {
    bool _limitReached = false;

    result.files.forEach((file) {
      double _fileSize = file.size / (1024 * 1024);

      // check if file reaches 1mb limit
      if (_fileSize <= 1) {
        return attachments.add(file);
      } else {
        _limitReached = true;
      }
    });

    if (_limitReached) {
      showReachedLimit();
    }

    notifyListeners();
  }

  void setCameraAttachment(PickedFile file) {
    attachments = [PlatformFile(path: file.path)];

    notifyListeners();
  }

  // show reached limit snackbar
  void showReachedLimit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Some images greater than 1MB limit will not be included'),
      ),
    );
  }

  // set current post value when editing
  void setCurrentData(PostModel post) {
    postController.text = post.content;
    currentAttachments.addAll(post.attachments);
  }
}
