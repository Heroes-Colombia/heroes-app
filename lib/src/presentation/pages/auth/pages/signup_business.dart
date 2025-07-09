import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/async_button_widget.dart';
import 'package:heroes_app/src/presentation/widgets/email_input_widget.dart';
import 'package:heroes_app/src/presentation/widgets/password_input_widget.dart';
import 'package:ionicons/ionicons.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

final _formKeySignUpBusiness = GlobalKey<FormBuilderState>();

@RoutePage()
class SignUpBusinessView extends StatefulWidget {
  const SignUpBusinessView({super.key});

  @override
  State<SignUpBusinessView> createState() => _SignUpBusinessViewState();
}

class _SignUpBusinessViewState extends State<SignUpBusinessView> {
  final locator = GetIt.instance;
  bool _isCreatingANewBusiness = false;

  @override
  Widget build(BuildContext context) {
    final texts = locator.get<AppConstants>().authTexts['signupBusinessView']!;
    var theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: FormBuilder(
        key: _formKeySignUpBusiness,
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
              child: Hero(
                tag: "logo",
                child: SvgPicture.asset(
                  theme.brightness == Brightness.dark
                      ? 'assets/images/heroes_black_logo.svg'
                      : 'assets/images/heroes_white_logo.svg',
                  height: 50,
                  width: double.infinity,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
            userSwitch(texts),
            _isCreatingANewBusiness
                ? businessRelatedFields(texts)
                : emptySpace(),
            _isCreatingANewBusiness ? personalInfoHeader(texts) : emptySpace(),
            userRelatedFields(texts),
            registerButton(context, texts),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter personalInfoHeader(Map<String, String> texts) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(left: 12.0, right: 12.0, top: 24.0),
        child: Text(texts['personalInfo']!),
      ),
    );
  }

  SliverToBoxAdapter userSwitch(Map<String, String> texts) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(texts['registerAsBusiness']!),
            Switch(
              value: _isCreatingANewBusiness,
              onChanged:
                  (value) => setState(() => _isCreatingANewBusiness = value),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter userRelatedFields(Map<String, String> texts) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormBuilderTextField(
              name: 'identification_card',
              key: const Key('identification_card'),
              decoration: InputDecoration(
                labelText: texts['identification-card-label']!,
                hintText: texts['identification-card-hint']!,
                border: const OutlineInputBorder(),
              ),
              validator: (value) => validateEmptyString(value, texts),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'first_name',
                    key: const Key('_register_business_first_name'),
                    validator: (value) => validateEmptyString(value, texts),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: texts['firstname-label']!,
                      hintText: texts['firstname-hint']!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'second_name',
                    key: const Key('_register_business_second_name'),
                    decoration: InputDecoration(
                      labelText: texts['secondname-label']!,
                      hintText: texts['secondname-hint']!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'first_last_name',
                    key: const Key('_register_business_last_name'),
                    validator: (value) => validateEmptyString(value, texts),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: texts['first-lastname-label']!,
                      hintText: texts['first-lastname-hint']!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'second_last_name',
                    decoration: InputDecoration(
                      labelText: texts['second-lastname-label']!,
                      hintText: texts['second-lastname-hint']!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FormBuilderTextField(
              name: 'rank',
              validator: (value) => validateEmptyString(value, texts),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: texts['rank-label']!,
                hintText: texts['rank-hint']!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            EmailInputWidget(
              keyName: 'signup_email',
              key: const Key('_register_business_signup_email'),
              name: 'email',
              label: texts['email-label']!,
              hintText: texts['email-hint']!,
            ),
            const SizedBox(height: 12),
            PasswordInput(
              keyName: '_register_business_password',
              name: 'password',
              label: texts['password-label']!,
              hintText: texts['password-hint']!,
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter businessRelatedFields(Map<String, String> texts) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormBuilderTextField(
              name: 'name',
              key: const Key('_register_business_name'),
              validator: (value) => validateEmptyString(value, texts),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: texts['name-label']!,
                hintText: texts['name-hint']!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FormBuilderTextField(
              name: 'address',
              key: const Key('_register_business_address'),
              validator: (value) => validateEmptyString(value, texts),
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                labelText: texts['address-label']!,
                hintText: texts['address-hint']!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FormBuilderTextField(
              name: 'identification',
              key: const Key('_register_business_identification'),
              decoration: InputDecoration(
                labelText: texts['identification-label']!,
                hintText: texts['identification-hint']!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            pictureField(texts, Theme.of(context)),
            const SizedBox(height: 12),
            EmailInputWidget(
              keyName: 'business_email',
              key: const Key('_register_business_signup_email'),
              name: 'business_email',
              label: texts['email-label']!,
              hintText: texts['email-hint']!,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'owner_name',
                    key: const Key('_register_business_owner_name'),
                    decoration: InputDecoration(
                      labelText: texts['ownername-label']!,
                      hintText: texts['ownername-hint']!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'phone_number',
                    key: const Key('_register_business_second_name'),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: texts['phone-label']!,
                      hintText: texts['phone-hint']!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter registerButton(
    BuildContext context,
    Map<String, String> texts,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsetsDirectional.only(
          bottom: 24,
          start: 12,
          end: 12,
          top: 12,
        ),
        child: AsyncButtonWidget(
          onPressed: () => doRegister(context, texts),
          buttonText: texts['signupButton']!,
        ),
      ),
    );
  }

  FormBuilderField<Object> pictureField(
    Map<String, String> texts,
    ThemeData theme,
  ) {
    return FormBuilderField(
      name: "RUT_img",
      key: const Key('RUT_img'),
      builder: (field) {
        return InkWell(
          onTap: () async {
            _showImagePickerDialog(context, field, texts, theme);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: field.hasError ? Colors.red : theme.colorScheme.primary,
              ),
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
                  field.value != null
                      ? texts["identification-card-img-filled"]!
                      : texts['identification-card-img-hint']!,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: theme.textTheme.bodyLarge!.fontSize,
                  ),
                ),
                Icon(
                  field.value != null
                      ? Ionicons.checkmark_circle_outline
                      : Ionicons.document_attach_outline,
                  color:
                      field.hasError ? Colors.red : theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  SliverToBoxAdapter emptySpace() {
    return SliverToBoxAdapter(child: Container());
  }

  String? validateEmptyString(value, texts) {
    final locator = GetIt.instance;
    final validator = locator.get<AppMethods>().emptyStringValidator(
      value,
      texts['genericValidator']!,
    );
    return validator;
  }

  //This method is used to register the business
  Future<void> doRegister(BuildContext context, texts) async {
    //First we validate the form
    final formIsValid = _formKeySignUpBusiness.currentState!.saveAndValidate();
    if (!formIsValid) return;

    //create a modifiable copy of the form data
    var formData = Map<String, dynamic>.from(
      _formKeySignUpBusiness.currentState!.value,
    );

    //If the user wants to create a new business attached to the new account
    if (_isCreatingANewBusiness) {
      // Validate all required fields before processing
      final requiredFields = ['email', 'password', 'first_name', 'first_last_name', 'rank'];
      for (String field in requiredFields) {
        if (formData[field] == null || formData[field].toString().isEmpty) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${field.replaceAll('_', ' ')} is required')));
          return;
        }
      }

      //Then create the user data and the business data
      final userData = User.toInitialFirebaseJson(
        formData,
        UserPermissions.business,
      );

      //Then we transform the address to a GeoPoint
      final address = formData['address'] as String?;
      if (address == null || address.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(texts['badLocation']!)));
        return;
      }

      final location = await transformToLatLng(address);
      if (location == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(texts['badLocation']!)));
        return;
      }

      formData['location'] = GeoPoint(location.latitude, location.longitude);
      final businessData = Business.toInitialFirebaseJson(formData);

      //Then we extract the image from the form data
      final businessRutImg = formData['RUT_img'];

      //Then we create the user in firestore and the business in firestore
      if (!context.mounted) return;
      final isBusinessCreated = await context.read<AuthCubit>().signUpBusiness(
        userData,
        businessData,
        businessRutImg,
      );

      //If the user and business is not created and logged in we show an error message
      if (!isBusinessCreated) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(texts['signupErrorTitle']!)));
        return;
      }
    }

    /*
     If the user wants to create a business account without a new business attached, 
     we create the user and log in
    */
    if (!_isCreatingANewBusiness) {
      final userData = User.toInitialFirebaseJson(
        formData,
        UserPermissions.business,
      );

      if (!context.mounted) return;
      final isUserCreatedAndLoggedInd = await context.read<AuthCubit>().signUp(
        userData,
        null,
      );

      //If the user is not created and logged in we show an error message
      if (!isUserCreatedAndLoggedInd) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(texts['signupErrorTitle']!)));
        return;
      }
    }

    //If the user is created and logged in we show a success message and navigate to the login page
    if (!context.mounted) return;
    locator.get<AppMethods>().showDialogAlert(
      context,
      texts["registerSuccess-title"]!,
      texts["registerSuccess-body"]!,
      texts["registerSuccess-button"]!,
      () {
        AutoRouter.of(context).replaceAll([LoginView(onResult: (callback) {})]);
      },
    );
  }

  Future<Location?> transformToLatLng(String address) async {
    try {
      var location = await locator.get<AppMethods>().getCoordinatesFromAddress(
        address,
      );
      return location;
    } catch (e) {
      log(
        'Error: $e, Function: transformToLatLng, File: owned_business_details_cubit.dart',
      );
      return null;
    }
  }

  void _showImagePickerDialog(
    BuildContext context,
    FormFieldState field,
    Map<String, String> texts,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(texts['identification-card-img-source']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Ionicons.camera_outline),
                title: Text(texts["identification-card-img-take-picture"]!),
                onTap: () async {
                  Navigator.of(context).pop();
                  final picture = await locator.get<AppMethods>().takePicture();
                  if (picture != null) {
                    field.didChange(picture);
                  }
                },
              ),
              ListTile(
                leading: Icon(Ionicons.image_outline),
                title: Text(
                  texts["identification-card-img-select-from-gallery"]!,
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final picture =
                      await locator.get<AppMethods>().selectPicture();
                  if (picture != null) {
                    field.didChange(picture);
                  }
                },
              ),
              ListTile(
                leading: Icon(Ionicons.document_outline),
                title: Text(texts["identification-card-img-select-pdf"]!),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pdfFile =
                      await locator.get<AppMethods>().selectPDFAsXFile();
                  if (pdfFile != null) {
                    field.didChange(pdfFile);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(texts['cancel'] ?? 'Cancel'),
            ),
          ],
        );
      },
    );
  }
}
