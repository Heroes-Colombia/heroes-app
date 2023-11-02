import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/presentation/cubits/profile/profile_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/async_button_widget.dart';

final updateUserForm = GlobalKey<FormBuilderState>();

@RoutePage()
class EditProfileView extends StatelessWidget {
  EditProfileView({Key? key}) : super(key: key);
  final locator = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var texts = locator.get<AppConstants>().dashBoardTexts['editprofileView']!;
    return WillPopScope(
      onWillPop: () async {
        context.read<ProfileCubit>().restoreProfileState();
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              switch (state.runtimeType) {
                case ProfileInitial:
                  context.read<ProfileCubit>().getInitialProfileInfo();
                  return loadingView(context, theme, texts);
                case ProfileLoaded:
                  return successView(context, state.user!, texts, theme);
                default:
                  return errorView(context, theme, texts);
              }
            },
          ),
        ),
      ),
    );
  }

  //This method is used to show a success view when the user info is loaded
  successView(BuildContext context, User user, texts, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(texts['title']!),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: FormBuilder(
              key: updateUserForm,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'first_name',
                          initialValue: user.firstName,
                          validator: (value) => locator
                              .get<AppMethods>()
                              .emptyStringValidator(
                                  value!, texts['empty-string']!),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: texts['firstname-hint']!,
                            labelText: texts['firstname-label']!,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'second_name',
                          initialValue: user.secondName,
                          validator: (value) => locator
                              .get<AppMethods>()
                              .emptyStringValidator(
                                  value!, texts['empty-string']!),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: texts['secondname-hint']!,
                            labelText: texts['secondname-label']!,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'first_last_name',
                      initialValue: user.firstLastName,
                      validator: (value) => locator
                          .get<AppMethods>()
                          .emptyStringValidator(value!, texts['empty-string']!),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: texts['first-lastname-hint']!,
                        labelText: texts['first-lastname-label']!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'second_last_name',
                      initialValue: user.secondLastName,
                      validator: (value) => locator
                          .get<AppMethods>()
                          .emptyStringValidator(value!, texts['empty-string']!),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: texts['second-lastname-hint']!,
                        labelText: texts['second-lastname-label']!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'rank',
                      initialValue: user.rank,
                      validator: (value) => locator
                          .get<AppMethods>()
                          .emptyStringValidator(value!, texts['empty-string']!),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: texts['rank-hint']!,
                        labelText: texts['rank-label']!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AsyncButtonWidget(
                      buttonText: texts['savechanges-button']!,
                      onPressed: () => changeUserInfo(context, texts),
                    )
                  ]),
            ),
          ),
        )
      ],
    );
  }

  //This method is used to show a loading view when the user info is loading
  loadingView(BuildContext context, ThemeData theme, texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(texts['title']!),
        ),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        )
      ],
    );
  }

  //This method is used to show an initial view when the user info started loading
  initialView(BuildContext context, ThemeData theme, texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(texts['title']!),
        ),
      ],
    );
  }

  //This method is used to show an error view when the user info is not loaded
  errorView(BuildContext context, ThemeData theme, texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(texts['error-title']!),
        ),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        )
      ],
    );
  }

  //This method is used to change the theme mode
  Future<void> changeUserInfo(BuildContext context, texts) async {
    //First we validate that the form is valid
    final formIsValid = updateUserForm.currentState!.saveAndValidate();
    if (formIsValid) {
      //If the form is valid we get the data
      final data = updateUserForm.currentState!.value;
      //Then we update the user info
      await context.read<ProfileCubit>().updateProfileInfo(data);
      if (!context.mounted) return;
      //If the user info is updated we show a snackbar with a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texts['success-content']!)),
      );
    } else {
      //If the form is not valid we show a snackbar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texts['error-content']!)),
      );
    }
  }
}
