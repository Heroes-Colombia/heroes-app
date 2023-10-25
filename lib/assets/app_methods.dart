import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
}
