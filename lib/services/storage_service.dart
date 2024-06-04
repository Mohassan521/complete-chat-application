import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  StorageService() {}

  Future<String?> uploadUserProfile(
      {required File file, required String uid}) async {
    Reference fileRef = _firebaseStorage
        .ref("/users/pfps")
        .child("$uid${p.extension(file.path)}");

    UploadTask task = fileRef.putFile(file);

    return task.then((value) {
      if (value.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
    });
  }

  Future<String?> uploadChatFiles(
      {required File file, required String chatID}) async {
    Reference fileRef = _firebaseStorage
        .ref("chats/$chatID")
        .child("${DateTime.now().toIso8601String()}${p.extension(file.path)}");

    UploadTask task = fileRef.putFile(file);

    return task.then((value) {
      if (value.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
    });
  }

  Future<String?> uploadChatPdfFiles(
      {required File file, required String chatID}) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      Reference fileRef = _firebaseStorage.ref("chats/$chatID").child(
          "${DateTime.now().toIso8601String()}${p.extension(file.path)}");

      // Start the file upload
      UploadTask task = fileRef.putFile(file);

      // Wait for the task to complete
      TaskSnapshot taskSnapshot = await task;

      if (taskSnapshot.state == TaskState.success) {
        String downloadURL = await fileRef.getDownloadURL();
        return downloadURL;
      } else {
        print('Upload failed: ${taskSnapshot.state}');
        return null;
      }
    } catch (e) {
      print('Error during file upload: $e');
      return null;
    }
  }
}
