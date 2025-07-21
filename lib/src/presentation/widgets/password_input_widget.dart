import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:ionicons/ionicons.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    required this.keyName,
    required this.name,
    required this.label,
    required this.hintText,
  });

  final String keyName;
  final String name;
  final String label;
  final String hintText;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final locator = GetIt.instance;
    final texts = locator.get<AppConstants>().authTexts['loginView']!;
    final theme = Theme.of(context);
    return FormBuilderTextField(
      obscureText: _obscureText,
      name: widget.name,
      key: Key(widget.keyName),
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Ionicons.eye_outline : Ionicons.eye_off_outline,
            color: theme.colorScheme.primary,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: const OutlineInputBorder(),
      ),
      validator:
          (value) => locator.get<AppMethods>().passwordValidator(
            value,
            texts['password-validator']!,
            texts['password-length-validator']!,
          ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
