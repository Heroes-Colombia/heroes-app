import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:flutter_svg/flutter_svg.dart';

@RoutePage()
class FirstTimeView extends StatelessWidget {
  FirstTimeView({super.key});
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
            decoration: BoxDecoration(color: theme.colorScheme.background),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: "logo",
                  child: SvgPicture.asset(
                    theme.brightness == Brightness.dark
                        ? 'assets/images/heroes_black_logo.svg'
                        : 'assets/images/heroes_white_logo.svg',
                    height: 100,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  authTexts['welcome']!,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: theme.textTheme.labelLarge?.fontSize,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onBackground),
                ),
                const SizedBox(height: 80),
                FilledButton(
                  onPressed: () =>
                      AutoRouter.of(context).push(LoginView(onResult: (p0) {})),
                  child: Text(authTexts['login']!),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => AutoRouter.of(context)
                      .push(SignUpView(onResult: (p0) {})),
                  child: Text(authTexts['register']!),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      AutoRouter.of(context).push(const SignUpBusinessView()),
                  child: Text(authTexts['registerAsBusiness']!),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
