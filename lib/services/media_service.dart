import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _imagePicker = ImagePicker();

  MediaService() {}

  Future<File?> getImageFromGallery() async {
    final XFile? _file =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (_file != null) {
      return File(_file.path);
    }
    return null;
  }

  Future<File?> getFileFromDevice() async {
    try {
      FilePickerResult? _filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'ppt', 'docx', 'pptx'],
      );

      if (_filePickerResult != null) {
        // File(_filePickerResult.paths.first)
        File file = File(_filePickerResult.files.single.path!);
        return file;
      }
      return null;
    } catch (e) {
      print("Something went wrong $e");
    }
  }
}
