import 'package:auto_route/auto_route.dart';
import 'package:heroes_app/src/config/router/auth_guard_router.dart';
import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        //Entry point
        CustomRoute(
          page: EntryPointView.page,
          initial: true,
          path: '/',
          transitionsBuilder: TransitionsBuilders.slideTop,
        ),

        //Auth routes
        CustomRoute(
          page: AuthView.page,
          path: '/welcome',
          transitionsBuilder: TransitionsBuilders.slideLeft,
          children: [
            AutoRoute(page: FirstTimeView.page, path: 'firstTime'),
            AutoRoute(page: LoginView.page, path: 'logIn'),
            AutoRoute(page: SignUpView.page, path: 'signUp'),
            AutoRoute(page: RestorePassword.page, path: 'restorePassword'),
            AutoRoute(page: SignUpBusinessView.page, path: 'signUpBusiness')
          ],
        ),

        //Dashboard routes
        CustomRoute(
          page: DashBoardView.page,
          path: '/dashboard',
          guards: [AuthGuard()],
          children: [
            CustomRoute(
              transitionsBuilder: TransitionsBuilders.noTransition,
              page: HomeSearchView.page,
              path: 'search',
              children: [
                CustomRoute(
                    page: SearchView.page,
                    path: '',
                    transitionsBuilder: TransitionsBuilders.noTransition),
                CustomRoute(
                  page: AllBusinessView.page,
                  path: 'allBusinessView',
                  transitionsBuilder: TransitionsBuilders.slideLeft,
                )
              ],
            ),
            AutoRoute(page: FavoritesView.page, path: 'favorites'),
            AutoRoute(page: ProfileView.page, path: 'settings'),
          ],
        ),

        //Individual hero routes
        CustomRoute(
          page: EditProfileView.page,
          path: '/editProfile',
          transitionsBuilder: TransitionsBuilders.slideLeft,
        ),
        CustomRoute(
          page: UnverifiedUserView.page,
          path: '/unverifiedUser',
          transitionsBuilder: TransitionsBuilders.slideLeft,
        ),
        CustomRoute(
          page: BusinessDetailsView.page,
          path: '/businessDetails',
          transitionsBuilder: TransitionsBuilders.slideLeft,
        ),
        CustomRoute(
            page: PromotionDetailsView.page,
            path: '/promotionDetails',
            transitionsBuilder: TransitionsBuilders.slideLeft),
      ];
}
