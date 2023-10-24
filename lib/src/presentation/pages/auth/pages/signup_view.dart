import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/async_button_widget.dart';
import 'package:heroes_app/src/presentation/widgets/email_input_widget.dart';
import 'package:heroes_app/src/presentation/widgets/password_input_widget.dart';
import 'package:ionicons/ionicons.dart';

final _formKey = GlobalKey<FormBuilderState>();

@RoutePage()
class SignUpView extends StatelessWidget {
  SignUpView({Key? key, required this.onResult}) : super(key: key);
  final Function(bool?) onResult;
  final locator = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    final texts = locator.get<AppConstants>().authTexts['signupView']!;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(texts['title']!),
            pinned: true,
            floating: true,
            snap: true,
          ),
          SliverToBoxAdapter(
            child: FormBuilder(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormBuilderTextField(
                      name: 'username',
                      key: const Key('username'),
                      decoration: InputDecoration(
                        labelText: texts['username-label']!,
                        hintText: texts['username-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => validateInputs(context, value),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'identification_card',
                      key: const Key('identification_card'),
                      decoration: InputDecoration(
                        labelText: texts['identification-card-label']!,
                        hintText: texts['identification-card-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => validateInputs(context, value),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    pictureField(texts, theme),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                            child: FormBuilderTextField(
                          name: 'first_name',
                          key: const Key('_register_first_name'),
                          decoration: InputDecoration(
                            labelText: texts['firstname-label']!,
                            hintText: texts['firstname-hint']!,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => validateInputs(context, value),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: FormBuilderTextField(
                          name: 'second_name',
                          key: const Key('_register_second_name'),
                          decoration: InputDecoration(
                            labelText: texts['secondname-label']!,
                            hintText: texts['secondname-hint']!,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => validateInputs(context, value),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                            child: FormBuilderTextField(
                          name: 'last_name',
                          key: const Key('_register_last_name'),
                          decoration: InputDecoration(
                            labelText: texts['lastname-label']!,
                            hintText: texts['lastname-hint']!,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => validateInputs(context, value),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: FormBuilderTextField(
                          name: 'rank',
                          decoration: InputDecoration(
                            labelText: texts['rank-label']!,
                            hintText: texts['rank-hint']!,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => validateInputs(context, value),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    EmailInputWidget(
                        keyName: 'signup_email',
                        key: const Key('signup_email'),
                        name: 'email',
                        label: texts['email-label']!,
                        hintText: texts['email-hint']!),
                    const SizedBox(height: 12),
                    PasswordInput(
                        keyName: '_register_password',
                        name: 'password',
                        label: texts['password-label']!,
                        hintText: texts['password-hint']!),
                    const SizedBox(height: 12),
                    AsyncButtonWidget(
                      onPressed: () => doRegister(context, texts),
                      buttonText: texts['signupButton']!,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FormBuilderField<Object> pictureField(
      Map<String, String> texts, ThemeData theme) {
    return FormBuilderField(
      validator: (value) {
        if (value == null) {
          return texts['genericValidator']!;
        }
        return null;
      },
      name: "identification_card_img",
      key: const Key('identification_card_img'),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        return InkWell(
          onTap: () async {
            final picture = await locator.get<AppMethods>().takePicture();
            if (picture == null) return;
            field.didChange(picture);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 18.0,
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    field.isValid
                        ? texts["identification-card-img-filled"]!
                        : texts['identification-card-img-hint']!,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: theme.textTheme.bodyLarge!.fontSize,
                    ),
                  ),
                  Icon(
                    field.isValid
                        ? Ionicons.camera_reverse_outline
                        : Ionicons.camera_outline,
                    color: theme.colorScheme.primary,
                  )
                ]),
          ),
        );
      },
    );
  }

  //This method is used to validate empty inputs
  String? validateInputs(BuildContext context, String? value) {
    final texts = locator.get<AppConstants>().authTexts['signupView']!;
    final message = locator
        .get<AppMethods>()
        .emptyStringValidator(value, texts['genericValidator']!);
    return message;
  }

  //This method is used to register the user
  Future<void> doRegister(BuildContext context, texts) async {
    //First we validate the form
    final formIsValid = _formKey.currentState!.saveAndValidate();
    if (!formIsValid) return;

    //create a modifiable copy of the form data and send it to the cubit to register the user
    final userData = Map<String, dynamic>.from(_formKey.currentState!.value);
    final isUserCreatedAndLoggedInd =
        await context.read<AuthCubit>().signUp(userData);

    //If the user is not created and logged in we show an error message
    if (!isUserCreatedAndLoggedInd) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(texts['signupErrorTitle']!)));
      return;
    }

    //If the user is created and logged in we navigate to the dashboard calling the onResult function,
    //this is used to validate the navigation to the dashboard from the auth guard
    if (!context.mounted) return;
    onResult.call(true);
    AutoRouter.of(context).replaceAll([const DashBoardView()]);
  }
}
