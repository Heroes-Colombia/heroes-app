import 'package:auto_route/auto_route.dart';
import 'package:heroes_app/src/config/router/auth_guard_router.dart';
import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        CustomRoute(page: AuthView.page, path: '/welcome', children: [
          AutoRoute(page: FirstTimeView.page, path: 'first-time'),
          AutoRoute(page: LoginView.page, path: 'login'),
          AutoRoute(page: SignUpView.page, path: 'signup'),
          AutoRoute(page: RestorePassword.page, path: 'restore-password'),
        ]),
        CustomRoute(
            page: DashBoardView.page,
            path: '/dashboard',
            initial: true,
            guards: [
              AuthGuard()
            ],
            children: [
              AutoRoute(page: SearchView.page, path: 'home'),
              AutoRoute(page: ProfileView.page, path: 'profile'),
              AutoRoute(page: ProfileView.page, path: 'settings'),
            ])
      ];
}
