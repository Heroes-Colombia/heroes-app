import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
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

    // Determine file extension and content type
    String fileExtension;
    String contentType;

    if (imageFile.path.toLowerCase().endsWith('.pdf')) {
      fileExtension = 'pdf';
      contentType = 'application/pdf';
    } else {
      fileExtension = 'jpg';
      contentType = 'image/jpeg';
    }

    //Get the reference to the image
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(identificationsRoute)
        .child(userRoute)
        .child(uid)
        .child("/identification.$fileExtension");

    //Set the metadata
    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {'picked-file-path': imageFile.path},
    );

    // Convert XFile to File
    File file = File(imageFile.path);

    //Upload the file
    await ref.putFile(file, metadata);
  }

  //This method is used to upload the business RUT identification
  Future<void> uploadBusinessRut(XFile imageFile, String uid) async {
    //Get the route to save the image
    final identificationsRoute =
        locator.get<AppConstants>().userIdentifications;
    final businessRutRoute = locator.get<AppConstants>().businessCollection;

    // Determine file extension and content type
    String fileExtension;
    String contentType;

    if (imageFile.path.toLowerCase().endsWith('.pdf')) {
      fileExtension = 'pdf';
      contentType = 'application/pdf';
    } else {
      fileExtension = 'jpg';
      contentType = 'image/jpeg';
    }

    //Get the reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(identificationsRoute)
        .child(businessRutRoute)
        .child(uid)
        .child("/identification.$fileExtension");

    //Set the metadata
    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {'picked-file-path': imageFile.path},
    );

    // Convert XFile to File
    File file = File(imageFile.path);

    //Upload the file
    await ref.putFile(file, metadata);
  }

  //This method is used to upload the promotion featured image
  Future<String> uploadBusinessFeaturedImage(
    XFile imageFile,
    String businessId,
  ) async {
    //Get the route to save the image
    final businessesImages = locator.get<AppConstants>().businessesImages;
    final featureImageRoute = locator.get<AppConstants>().featureImage;

    //Create a regex to get the extension of the image
    var imageExtensionRegex = RegExp(r'(\w{3,4}$)');
    var imageExtension = imageExtensionRegex.stringMatch(imageFile.path);

    //Get the reference to the image
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(businessesImages)
        .child(businessId)
        .child(featureImageRoute)
        .child("/featured_image.$imageExtension");

    //Set the metadata
    final metadata = SettableMetadata(
      contentType: 'image/$imageExtension',
      customMetadata: {'picked-file-path': imageFile.path},
    );

    // Convert XFile to File
    File file = File(imageFile.path);

    //Upload the image
    var result = await ref.putFile(file, metadata);
    var urlPath = await result.ref.getDownloadURL();

    return urlPath;
  }

  //This method is used to upload the promotion featured image
  Future<String> uploadPromotionFeaturedImage(
    XFile imageFile,
    String businessId,
  ) async {
    //Get the route to save the image
    final promotionsImages = locator.get<AppConstants>().promotionImages;
    final featureImageRoute = locator.get<AppConstants>().featureImage;

    //Create a regex to get the extension of the image
    var imageExtensionRegex = RegExp(r'(\w{3,4}$)');
    var imageExtension = imageExtensionRegex.stringMatch(imageFile.path);

    //Get the reference to the image
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(promotionsImages)
        .child(businessId)
        .child(featureImageRoute)
        .child("/featured_image.$imageExtension");

    //Set the metadata
    final metadata = SettableMetadata(
      contentType: 'image/$imageExtension',
      customMetadata: {'picked-file-path': imageFile.path},
    );

    // Convert XFile to File
    File file = File(imageFile.path);

    //Upload the image
    var result = await ref.putFile(file, metadata);
    var urlPath = await result.ref.getDownloadURL();

    return urlPath;
  }

  //This method is used to delete the promotion featured image
  Future<void> deletePromotionFeaturedImage(Promotion promotion) async {
    // First, get the route to save the image
    final promotionsImages = locator.get<AppConstants>().promotionImages;
    final featureImageRoute = locator.get<AppConstants>().featureImage;

    // Using a regex, get the extension of the image
    var imageExtensionRegex = RegExp(r'\.(\w{3,4})\?');
    var match = imageExtensionRegex.firstMatch(promotion.featuredImage);
    var imageExtension = match?.group(1);

    // Get the reference to the image
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(promotionsImages)
        .child(promotion.documentId!)
        .child(featureImageRoute)
        .child("/featured_image.$imageExtension");

    // Delete the image
    await ref.delete();
  }
}
