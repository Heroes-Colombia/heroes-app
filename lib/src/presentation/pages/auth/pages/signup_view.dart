import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/async_button_widget.dart';
import 'package:heroes_app/src/presentation/widgets/email_input_widget.dart';
import 'package:heroes_app/src/presentation/widgets/password_input_widget.dart';

final _formKey = GlobalKey<FormBuilderState>();

@RoutePage()
class SignUpView extends StatelessWidget {
  SignUpView({Key? key, required this.onResult}) : super(key: key);
  final Function(bool?) onResult;
  final locator = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    final texts = locator.get<AppConstants>().authTexts['signupView']!;
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
          SliverFillRemaining(
            hasScrollBody: false,
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
                    ),
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
