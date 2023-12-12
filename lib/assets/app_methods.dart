import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class AppMethods {
  //Validate email input field
  //Use this method in the validator property of the FormBuilderTextField widget
  String? validateEmail(String? value, Map<String, String> texts) {
    if (value == null || value.isEmpty) {
      return texts['email-validator']!;
    }
    if (!RegExp(
      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
    ).hasMatch(value)) {
      return texts['email-validator']!;
    }
    return null;
  }

  //Validate empty input field
  String? emptyStringValidator(String? value, String message) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  }

  //Validate empty input
  dynamic emptyInputValidator(dynamic value, String message) {
    if (value == null) {
      return message;
    }
    return null;
  }

  //Validate empty input field and with a max length
  String? emptyStringValidatorWithMaxLength(
    String? value,
    String message,
    int maxLength,
  ) {
    if (value == null || value.isEmpty) {
      return message;
    }
    if (value.length > maxLength) {
      return message;
    }
    return null;
  }

  //Validate empty input field with double as value
  String? nullDoubleValidator(double? value, String message) {
    if (value == null) {
      return message;
    }
    return null;
  }

  //Validate password input field
  String? passwordValidator(
      String? value, String emptyString, String invalidLength) {
    if (value == null || value.isEmpty) {
      return emptyString;
    }
    if (value.length < 6) {
      return invalidLength;
    }
    return null;
  }

  //Get the picture from the camera
  Future<XFile?> takePicture() async {
    final ImagePicker picker = ImagePicker();
    // Capture a photo.
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    return photo;
  }

  //Get the picture from the device gallery
  Future<XFile?> selectPicture() async {
    final ImagePicker picker = ImagePicker();
    // Capture a photo.
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    return photo;
  }

  //Show dialog alert
  Future<void> showDialogAlert(BuildContext context, String title, String body,
      String button, Function callback) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(body),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(child: Text(button), onPressed: () => callback()),
          ],
        );
      },
    );
  }

  //This method is used to uppercase the first letter of a string
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  //This method is used to get the user location
  Future<LocationData?> getUserLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  //This method is used to convert from address to coordinates
  Future<geocoding.Location?> getCoordinatesFromAddress(String address) async {
    List<geocoding.Location> locations =
        await geocoding.locationFromAddress(address);
    return locations.first;
  }

  //This method is used to open app from url
  Future<void> openAppFromUri(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Error trying to open the following url: $url');
    }
  }
}
