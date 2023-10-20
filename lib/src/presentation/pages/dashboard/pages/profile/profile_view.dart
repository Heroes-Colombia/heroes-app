import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class ProfileView extends StatelessWidget {
  ProfileView({Key? key}) : super(key: key);
  final locator = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var texts = locator.get<AppConstants>().dashBoardTexts['profileView']!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(texts['title']!),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListBody(children: [
                const SizedBox(height: 16),
                Text(texts['account']!, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Ionicons.person_outline),
                  title: Text(texts['edit-profile']!),
                  onTap: () => context.router.push(EditProfileView()),
                ),
                ListTile(
                    leading: const Icon(Ionicons.log_out_outline),
                    title: Text(texts['logout']!),
                    onTap: () => doLogOut(context, texts)),
                const SizedBox(height: 16),
                Text(texts['settings']!, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Ionicons.moon_outline),
                  title: Text(texts['dark-mode']!),
                  trailing: Switch(
                    value: AdaptiveTheme.of(context).mode ==
                        AdaptiveThemeMode.dark,
                    onChanged: (_) => changeThemeMode(context),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  //This method is used to log out the user
  void doLogOut(BuildContext context, texts) async {
    //First we log out the user
    final userIsLoggedIn = await context.read<AuthCubit>().logOut();
    if (userIsLoggedIn) {
      if (!context.mounted) return;
      //If the user is logged out we navigate to the auth view
      context.router.replaceAll([const AuthView()]);
    } else {
      if (!context.mounted) return;
      //If the user is not logged out we show a snackbar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts['logout-error-message']!),
        ),
      );
    }
  }

//This method is used to change the theme mode
  void changeThemeMode(BuildContext context) {
    //First we get the current theme mode
    final themeMode = AdaptiveTheme.of(context).mode;
    //Then we change the theme mode
    if (themeMode == AdaptiveThemeMode.dark) {
      AdaptiveTheme.of(context).setLight();
    } else {
      AdaptiveTheme.of(context).setDark();
    }
  }
}
