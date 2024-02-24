import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/async_button_widget.dart';
import 'package:heroes_app/src/presentation/widgets/email_input_widget.dart';
import 'package:heroes_app/src/presentation/widgets/password_input_widget.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_svg/svg.dart';

final _formKey = GlobalKey<FormBuilderState>();

@RoutePage()
class SignUpView extends StatelessWidget {
  SignUpView({super.key, required this.onResult});
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
            title: Text(
              texts['title']!,
              style: TextStyle(
                color: theme.colorScheme.onBackground,
                fontSize: theme.textTheme.bodyLarge!.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                    Hero(
                      tag: "logo",
                      child: SvgPicture.asset(
                        theme.brightness == Brightness.dark
                            ? 'assets/images/heroes_black_logo.svg'
                            : 'assets/images/heroes_white_logo.svg',
                        height: 50,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 40),
                    FormBuilderTextField(
                      name: 'license',
                      key: const Key('license'),
                      decoration: InputDecoration(
                        labelText: texts['license-label']!,
                        hintText: texts['license-hint']!,
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
                          name: 'first_last_name',
                          key: const Key('_register_last_name'),
                          decoration: InputDecoration(
                            labelText: texts['first-lastname-label']!,
                            hintText: texts['first-lastname-hint']!,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => validateInputs(context, value),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: FormBuilderTextField(
                          name: 'second_last_name',
                          decoration: InputDecoration(
                            labelText: texts['second-lastname-label']!,
                            hintText: texts['second-lastname-hint']!,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => validateInputs(context, value),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FormBuilderDropdown(
                      name: 'rank',
                      key: const Key('_register_rank'),
                      dropdownColor: theme.colorScheme.background,
                      decoration: InputDecoration(
                        labelText: texts['rank-label']!,
                        hintText: texts['rank-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                      items: getRanks(context),
                      validator: (value) => validateInputs(context, value),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
    final formData = Map<String, dynamic>.from(_formKey.currentState!.value);
    final userData = User.toInitialFirebaseJson(formData, null);

    //Then we extract the image from the form data
    final identificationImage = formData['identification_card_img'];

    final isUserCreatedAndLoggedInd =
        await context.read<AuthCubit>().signUp(userData, identificationImage);

    //If the user is not created and logged in we show an error message
    if (!isUserCreatedAndLoggedInd) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts['signupErrorTitle']!),
        ),
      );
      return;
    }

    //If the user is created and logged in we show a success message and navigate to the login page
    if (!context.mounted) return;
    locator.get<AppMethods>().showDialogAlert(
        context,
        texts["registerSuccess-title"]!,
        texts["registerSuccess-body"]!,
        texts["registerSuccess-button"]!, () {
      AutoRouter.of(context).replaceAll([LoginView(onResult: (callback) {})]);
    });
  }

  //This method is used to get the ranks from the constants file
  List<DropdownMenuItem<String>> getRanks(BuildContext context) {
    List<DropdownMenuItem<String>> dropdownItems = [];
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var ranksMap = locator.get<AppConstants>().ranks;

    ranksMap.forEach((category, subCategories) {
      String categoryValue = "Category_$category";
      dropdownItems.add(
        DropdownMenuItem(
          enabled: false,
          value: categoryValue,
          child: Text(
            locator.get<AppMethods>().capitalize(category),
            style: TextStyle(
                fontSize: theme.textTheme.bodyLarge!.fontSize,
                fontWeight: theme.textTheme.labelLarge!.fontWeight,
                color: theme.colorScheme.primary),
          ),
        ),
      );

      subCategories.forEach((subCategory, options) {
        String subCategoryValue = "SubCategory_$subCategory";
        dropdownItems.add(
          DropdownMenuItem(
            enabled: false,
            value: subCategoryValue,
            child: Container(
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                locator.get<AppMethods>().capitalize(subCategory),
                style: TextStyle(
                    fontSize: theme.textTheme.labelMedium!.fontSize,
                    fontWeight: theme.textTheme.labelLarge!.fontWeight,
                    color: theme.colorScheme.primary.withOpacity(0.6)),
              ),
            ),
          ),
        );

        for (var option in options) {
          String optionValue = option;
          dropdownItems.add(
            DropdownMenuItem(
              value: "${category}_${subCategory}_$optionValue",
              child: Container(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  locator.get<AppMethods>().capitalize(option),
                  style: TextStyle(
                      fontSize: theme.textTheme.labelMedium!.fontSize,
                      fontWeight: theme.textTheme.labelLarge!.fontWeight,
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          );
        }
      });

      dropdownItems.add(
        DropdownMenuItem(
          value: "",
          enabled: false,
          child: Container(
            width: double.infinity,
            height: 1,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    });

    return dropdownItems;
  }
}
