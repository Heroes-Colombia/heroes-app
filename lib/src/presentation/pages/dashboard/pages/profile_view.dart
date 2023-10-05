import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Hola, Andrés Chávez!'),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListBody(children: [
                const SizedBox(height: 16),
                Text('Cuenta', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Ionicons.person_outline),
                  title: const Text('Editar perfil'),
                  onTap: () {},
                ),
                ListTile(
                    leading: const Icon(Ionicons.log_out_outline),
                    title: const Text('Cerrar sesión'),
                    onTap: () => doLogOut(context)),
                const SizedBox(height: 16),
                Text('Ajustes', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Ionicons.moon_outline),
                  title: const Text('Tema oscuro'),
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
