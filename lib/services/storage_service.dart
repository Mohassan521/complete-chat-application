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
}
