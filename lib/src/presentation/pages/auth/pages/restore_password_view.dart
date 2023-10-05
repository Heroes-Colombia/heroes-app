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
  RestorePassword({Key? key}) : super(key: key);
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
                    EmailInputWidget(
                        keyName: 'restore_password_email',
                        name: 'email',
                        label: texts['email-label']!,
                        hintText: texts['email-hint']!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          sentRecoverPasswordEmail(context, theme, texts),
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

  Future<void> sentRecoverPasswordEmail(
      BuildContext context, theme, texts) async {
    if (_formKey.currentState!.saveAndValidate()) {
      final email = _formKey.currentState!.fields['email']!.value;
      final emailWasSend =
          await context.read<AuthCubit>().restorePassword(email);
      if (!context.mounted) return;
      if (emailWasSend) {
        emailSentSnackBar(context, texts);
      } else {
        badEmailSnackBar(context, texts, theme);
        //mark email field as invalid and focus it
      }
    }
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> emailSentSnackBar(
      BuildContext context, Map<String, String> texts) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texts['email-sent']!),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> badEmailSnackBar(
      BuildContext context, Map<String, String> texts, ThemeData theme) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(texts['email-not-found']!),
          backgroundColor: theme.colorScheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
              textColor: theme.colorScheme.primary,
              label: texts['try-again']!,
              onPressed: () =>
                  _formKey.currentState!.fields['email']!.focus())),
    );
  }
}
