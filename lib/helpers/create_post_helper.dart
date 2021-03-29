import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CreatePostHelper extends ChangeNotifier {
  List<PlatformFile> attachments = [];
  BuildContext context;
  final TextEditingController postController = new TextEditingController();

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

  void showReachedLimit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Some images greater than 1MB limit will not be included'),
      ),
    );
  }
}
