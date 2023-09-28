import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';

@RoutePage()
class FirstTimeView extends StatelessWidget {
  const FirstTimeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.background,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Text(
                    '¡Bienvenido, Héroe!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    AutoRouter.of(context).push(LoginView(onResult: (p0) {}));
                  },
                  child: const Text('Iniciar sesión'),
                ),
                TextButton(
                  onPressed: () {
                    AutoRouter.of(context).push(const SignUpView());
                  },
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
