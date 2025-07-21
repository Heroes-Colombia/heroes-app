import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/email_input_widget.dart';

final _formKey = GlobalKey<FormBuilderState>();

@RoutePage()
class RestorePassword extends StatelessWidget {
  RestorePassword({super.key});
  final locator = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    final texts = locator.get<AppConstants>().authTexts['restorePasswordView']!;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              texts['title']!,
              style: TextStyle(
                color: theme.colorScheme.onBackground,
                fontSize: theme.textTheme.bodyLarge!.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      texts['sub-title']!,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: theme.textTheme.labelLarge?.fontSize,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EmailInputWidget(
                      keyName: 'restore_password_email',
                      name: 'email',
                      label: texts['email-label']!,
                      hintText: texts['email-hint']!,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed:
                          () => sentRecoverPasswordEmail(context, theme, texts),
                      child: Text(texts['restoreButton']!),
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

  //This method is used to send the email to the user
  Future<void> sentRecoverPasswordEmail(
    BuildContext context,
    theme,
    texts,
  ) async {
    if (_formKey.currentState!.saveAndValidate()) {
      //First we save the email
      final email = _formKey.currentState!.fields['email']!.value;
      //Then we call the restorePassword method from the AuthCubit
      final resetResult = await context.read<AuthCubit>().restorePassword(
        email,
      );

      if (!context.mounted) return;
      //If the email was send we show a snackbar with a confirmation message or if not we show a snackbar with a message to try again
      if (resetResult.success) {
        emailSentSnackBar(context, texts);
      } else {
        badEmailSnackBar(context, texts, theme);
      }
    }
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> emailSentSnackBar(
    BuildContext context,
    Map<String, String> texts,
  ) {
    return ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texts['email-sent']!)));
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> badEmailSnackBar(
    BuildContext context,
    Map<String, String> texts,
    ThemeData theme,
  ) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texts['email-not-found']!),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          textColor: theme.colorScheme.primary,
          label: texts['try-again']!,
          onPressed: () => _formKey.currentState!.fields['email']!.focus(),
        ),
      ),
    );
  }
}
