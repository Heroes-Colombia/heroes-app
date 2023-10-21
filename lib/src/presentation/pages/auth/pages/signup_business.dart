import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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

final _formKeySignUpBusiness = GlobalKey<FormBuilderState>();

@RoutePage()
class SignUpBusinessView extends StatefulWidget {
  const SignUpBusinessView({Key? key}) : super(key: key);

  @override
  State<SignUpBusinessView> createState() => _SignUpBusinessViewState();
}

class _SignUpBusinessViewState extends State<SignUpBusinessView> {
  final locator = GetIt.instance;
  bool _isCreatingANewBusiness = false;

  @override
  Widget build(BuildContext context) {
    final texts = locator.get<AppConstants>().authTexts['signupBusinessView']!;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: FormBuilder(
        key: _formKeySignUpBusiness,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(texts['title']!),
              pinned: true,
              floating: true,
              snap: true,
            ),
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
            Text(texts['registerComercio']!),
            Switch(
                value: _isCreatingANewBusiness,
                onChanged: (value) =>
                    setState(() => _isCreatingANewBusiness = value)),
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
              name: 'username',
              key: const Key('_register_business_username'),
              validator: (value) => validateEmptyString(value, texts),
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  key: const Key('_register_business_first_name'),
                  validator: (value) => validateEmptyString(value, texts),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  key: const Key('_register_business_second_name'),
                  validator: (value) => validateEmptyString(value, texts),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  key: const Key('_register_business_last_name'),
                  validator: (value) => validateEmptyString(value, texts),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  validator: (value) => validateEmptyString(value, texts),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                key: const Key('_register_business_signup_email'),
                name: 'email',
                label: texts['email-label']!,
                hintText: texts['email-hint']!),
            const SizedBox(height: 12),
            PasswordInput(
                keyName: '_register_business_password',
                name: 'password',
                label: texts['password-label']!,
                hintText: texts['password-hint']!),
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
              validator: (value) => validateEmptyString(value, texts),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: texts['identification-label']!,
                hintText: texts['identification-hint']!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            EmailInputWidget(
                keyName: 'business_email',
                key: const Key('_register_business_signup_email'),
                name: 'business_email',
                label: texts['email-label']!,
                hintText: texts['email-hint']!),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: FormBuilderTextField(
                  name: 'owner_name',
                  key: const Key('_register_business_owner_name'),
                  validator: (value) => validateEmptyString(value, texts),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: texts['ownername-label']!,
                    hintText: texts['ownername-hint']!,
                    border: const OutlineInputBorder(),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: FormBuilderTextField(
                  name: 'phone_number',
                  key: const Key('_register_business_second_name'),
                  validator: (value) => validateEmptyString(value, texts),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: texts['phone-label']!,
                    hintText: texts['phone-hint']!,
                    border: const OutlineInputBorder(),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter registerButton(
      BuildContext context, Map<String, String> texts) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsetsDirectional.only(
            bottom: 24, start: 12, end: 12, top: 12),
        child: AsyncButtonWidget(
          onPressed: () => doRegister(context, texts),
          buttonText: texts['signupButton']!,
        ),
      ),
    );
  }

  SliverToBoxAdapter emptySpace() {
    return SliverToBoxAdapter(child: Container());
  }

  String? validateEmptyString(value, texts) {
    final locator = GetIt.instance;
    final validator = locator
        .get<AppMethods>()
        .emptyStringValidator(value, texts['genericValidator']!);
    return validator;
  }

  //This method is used to register the business
  Future<void> doRegister(BuildContext context, texts) async {
    //First we validate the form
    final formIsValid = _formKeySignUpBusiness.currentState!.saveAndValidate();
    if (!formIsValid) return;

    //create a modifiable copy of the form data
    final formData =
        Map<String, dynamic>.from(_formKeySignUpBusiness.currentState!.value);

    //If the user wants to create a new business attached to the new account
    if (_isCreatingANewBusiness) {
      //Then create the user data and the business data
      final userData =
          User.toInitialFirebaseJson(formData, UserPermissions.business);
      final businessData = Business.toInitialFirebaseJson(formData);

      //Then we create the user in firestore and the business in firestore
      final isBusinessCreated = await context
          .read<AuthCubit>()
          .signUpBusiness(userData, businessData);

      //If the user and business is not created and logged in we show an error message
      if (!isBusinessCreated) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(texts['signupErrorTitle']!)));
        return;
      }
    }

    /*
     If the user wants to create a business account without a new business attached, 
     we create the user and log in
    */
    if (!_isCreatingANewBusiness) {
      final userData =
          User.toInitialFirebaseJson(formData, UserPermissions.business);

      if (!context.mounted) return;
      final isUserCreatedAndLoggedInd =
          await context.read<AuthCubit>().signUp(userData);

      //If the user is not created and logged in we show an error message
      if (!isUserCreatedAndLoggedInd) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(texts['signupErrorTitle']!)));
        return;
      }
    }

    /*
     If the user is created and logged in we navigate to the dashboard calling the onResult function,
     this is used to validate the navigation to the dashboard from the auth guard
    */
    if (!context.mounted) return;
    AutoRouter.of(context).replaceAll([const DashBoardView()]);
  }
}
