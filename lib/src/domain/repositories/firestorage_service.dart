import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStorageService {
  final locator = GetIt.instance;

  //This method is used to upload the user identification
  Future<void> uploadUserIdentification(XFile imageFile, String uid) async {
    //Get the route to save the image
    final identificationsRoute =
        locator.get<AppConstants>().userIdentifications;
    final userRoute = locator.get<AppConstants>().usersCollection;

    //Get the reference to the image
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(identificationsRoute)
        .child(userRoute)
        .child(uid)
        .child("/identification.jpg");

    //Set the metadata
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': imageFile.path},
    );

    // Convert XFile to File
    File file = File(imageFile.path);

    //Upload the image
    await ref.putFile(file, metadata);
  }

  Future<void> uploadBusinessRut(XFile imageFile, String uid) async {
    //Get the route to save the image
    final identificationsRoute =
        locator.get<AppConstants>().userIdentifications;
    final businessRutRoute = locator.get<AppConstants>().businessCollection;

    //Get the reference to the image
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(identificationsRoute)
        .child(businessRutRoute)
        .child(uid)
        .child("/identification.jpg");

    //Set the metadata
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': imageFile.path},
    );

    // Convert XFile to File
    File file = File(imageFile.path);

    //Upload the image
    await ref.putFile(file, metadata);
  }
}
