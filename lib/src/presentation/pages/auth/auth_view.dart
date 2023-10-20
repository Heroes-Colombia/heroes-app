import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';

@RoutePage()
class AuthView extends StatelessWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        FirstTimeView(),
        LoginView(onResult: (willRedirectToDashboard) {}),
        SignUpView(onResult: (willRedirectToDashboard) {}),
        RestorePassword()
      ],
      builder: (context, child) {
        return Scaffold(body: child);
      },
    );
  }
}
