import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';

class EmailInputWidget extends StatelessWidget {
  const EmailInputWidget(
      {Key? key,
      required this.keyName,
      required this.name,
      required this.label,
      required this.hintText})
      : super(key: key);

  final String keyName;
  final String name;
  final String label;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final locator = GetIt.instance;
    final texts = locator.get<AppConstants>().authTexts['restorePasswordView']!;
    return FormBuilderTextField(
      name: name,
      key: Key(keyName),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          locator.get<AppMethods>().validateEmail(value, texts),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
