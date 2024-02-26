import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/async_button_widget.dart';
import 'package:heroes_app/src/presentation/widgets/email_input_widget.dart';
import 'package:heroes_app/src/presentation/widgets/password_input_widget.dart';

final _formKey = GlobalKey<FormBuilderState>();

@RoutePage()
class LoginView extends StatelessWidget {
  final Function(bool?) onResult;
  LoginView({super.key, required this.onResult});
  final locator = GetIt.instance;
  @override
  Widget build(BuildContext context) {
    final authTexts = locator.get<AppConstants>().authTexts['loginView']!;
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: FormBuilder(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: "logo",
                  child: SvgPicture.asset(
                    theme.brightness == Brightness.dark
                        ? 'assets/images/heroes_black_logo.svg'
                        : 'assets/images/heroes_white_logo.svg',
                    height: 100,
                    width: double.infinity,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  authTexts['sub-title']!,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: theme.textTheme.labelLarge?.fontSize,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onBackground),
                ),
                const SizedBox(height: 28),
                EmailInputWidget(
                    keyName: "email",
                    name: "email",
                    label: authTexts['email-label']!,
                    hintText: authTexts['email-hint']!),
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
    );
  }

  //This method is used to login the user
  Future<void> _loginUser(
      BuildContext context, Map<String, String> texts) async {
    //First we validate the form
    final formIsValid = _formKey.currentState!.saveAndValidate();
    if (formIsValid) {
      final formData = _formKey.currentState!.value;
      final userIsValid =
          await context.read<AuthCubit>().logIn(formData, context);

      if (!userIsValid) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(texts['loginErrorContent']!),
          ),
        );
      }
    }
  }
}
