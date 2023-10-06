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
                    onTap: () => doLogOut(context)),
                const SizedBox(height: 16),
                Text(texts['settings']!, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Ionicons.moon_outline),
                  title: Text(texts['dark-mode']!),
                  onTap: () {},
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void doLogOut(BuildContext context) async {
    final userIsLoggedIn = await context.read<AuthCubit>().logOut();
    if (userIsLoggedIn) {
      if (!context.mounted) return;
      context.router.replaceAll([const AuthView()]);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error al cerrar sesión'),
        ),
      );
    }
  }
}
