import 'package:auto_route/auto_route.dart';
import 'package:heroes_app/src/config/router/auth_guard_router.dart';
import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        //Auth routes
        CustomRoute(
          page: AuthView.page,
          path: '/welcome',
          transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
          children: [
            AutoRoute(page: FirstTimeView.page, path: 'firstTime'),
            AutoRoute(page: LoginView.page, path: 'logIn'),
            AutoRoute(page: SignUpView.page, path: 'signUp'),
            AutoRoute(page: RestorePassword.page, path: 'restorePassword'),
          ],
        ),
        //Dashboard routes
        CustomRoute(
          page: DashBoardView.page,
          path: '/dashboard',
          initial: true,
          guards: [AuthGuard()],
          children: [
            AutoRoute(page: SearchView.page, path: 'search'),
            AutoRoute(page: FavoritesView.page, path: 'favorites'),
            AutoRoute(page: ProfileView.page, path: 'settings'),
          ],
        ),
        //Individual hero routes
        CustomRoute(
          page: EditProfileView.page,
          path: '/editProfile',
          transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
        ),
      ];
}
