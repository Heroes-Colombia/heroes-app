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

  String? emptyStringValidator(String? value, String message) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  }

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
}
