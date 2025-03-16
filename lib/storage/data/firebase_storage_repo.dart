import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:socialx/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo{

  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images");
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes as String, fileName, "profile_images");
  }

  /*
  * HELPER METHODS- tp upload files to storage
  * */

//mobile platforms [file]
Future<String?> _uploadFile(String path, String fileName, String folder) async{
  try{
   //get file
   final file =  File(path);

   //find place to store
    final storageRef = storage.ref().child('$folder/$fileName');

    //upload
    final uploadTask = await storageRef.putFile(file);

    //get image download URL
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return downloadUrl;

  }catch(e){
    return null;
  }
}

//web platform (bytes)
  Future<String?> _uploadFileBytes(String fileBytes, String fileName, String folder) async{
    try{

      //find place to store
      final storageRef = storage.ref().child('$folder/$fileName');

      //upload
      final uploadTask = await storageRef.putData(fileBytes as Uint8List);

      //get image download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;

    }catch(e){
      return null;
    }
  }
}