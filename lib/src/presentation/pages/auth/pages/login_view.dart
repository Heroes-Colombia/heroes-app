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
import 'package:heroes_app/src/presentation/widgets/password_input_widget.dart';

final _formKey = GlobalKey<FormBuilderState>();

@RoutePage()
class LoginView extends StatelessWidget {
  final Function(bool?) onResult;
  LoginView({Key? key, required this.onResult}) : super(key: key);
  final locator = GetIt.instance;
  @override
  Widget build(BuildContext context) {
    final authTexts = locator.get<AppConstants>().authTexts['loginView']!;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(authTexts['title']!),
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
                      name: 'email',
                      key: const Key('_login_email'),
                      decoration: InputDecoration(
                        labelText: authTexts['email-label']!,
                        hintText: authTexts['email-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => locator
                          .get<AppMethods>()
                          .validateEmail(value, authTexts),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 12),
                    PasswordInput(
                        keyName: '_login_password',
                        name: 'password',
                        label: authTexts['password-label']!,
                        hintText: authTexts['password-hint']!),
                    const SizedBox(height: 12),
                    AsyncButtonWidget(
                      onPressed: () => _loginUser(context, authTexts),
                      buttonText: authTexts['loginButton']!,
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () =>
                          AutoRouter.of(context).push(RestorePassword()),
                      child: Text(authTexts['forgotPassword']!),
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

  Future<void> _loginUser(
      BuildContext context, Map<String, String> texts) async {
    final formIsValid = _formKey.currentState!.saveAndValidate();
    if (formIsValid) {
      final userIsLoggedIn =
          await context.read<AuthCubit>().logIn(_formKey.currentState!.value);
      if (!context.mounted) return;
      if (userIsLoggedIn) {
        onResult.call(true);
        AutoRouter.of(context).replaceAll([const DashBoardView()]);
      }
      _showDialogAlert(context, texts);
    }
  }

  Future<void> _showDialogAlert(
      BuildContext context, Map<String, String> texts) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(texts['loginErrorTitle']!),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(texts['loginErrorContent']!),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(texts['loginErrorButton']!),
                onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }
}
