import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';

@RoutePage()
class FirstTimeView extends StatelessWidget {
  FirstTimeView({Key? key}) : super(key: key);
  final GetIt locator = GetIt.instance;
  @override
  Widget build(BuildContext context) {
    final authTexts = locator.get<AppConstants>().authTexts['welcomeView']!;
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
                    authTexts['welcome']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary),
                  ),
                ),
                const Spacer(),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => AutoRouter.of(context)
                          .push(SignUpView(onResult: (p0) {})),
                      child: Text(authTexts['register']!),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => AutoRouter.of(context)
                          .push(LoginView(onResult: (p0) {})),
                      child: Text(authTexts['login']!),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      AutoRouter.of(context).push(const SignUpBusinessView()),
                  child: Text(authTexts['registerAsBusiness']!),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
