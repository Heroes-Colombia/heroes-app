import 'package:auto_route/auto_route.dart';
import 'package:heroes_app/src/config/router/auth_guard_router.dart';
import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
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
        AutoRoute(page: SignUpBusinessView.page, path: 'signUpBusiness'),
        AutoRoute(page: MilitaryVerificationView.page, path: 'militaryVerification'),
      ],
    ),

    //Onboarding routes
    CustomRoute(
      page: IntroRouteView.page,
      path: '/intro',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),

    //Dashboard routes
    CustomRoute(
      page: DashBoardView.page,
      path: '/dashboard',
      guards: [AuthGuard()],
      children: [
        CustomRoute(
          page: HomeSearchView.page,
          path: 'search',
          children: [
            CustomRoute(page: SearchView.page, path: ''),
            CustomRoute(
              page: AllBusinessView.page,
              path: 'allBusinessView',
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
            CustomRoute(
              page: AllPromotionsView.page,
              path: 'allPromotionsView',
              transitionsBuilder: TransitionsBuilders.fadeIn,
            ),
          ],
        ),
        AutoRoute(page: FavoritesView.page, path: 'favorites'),
        AutoRoute(page: ProfileView.page, path: 'settings'),
      ],
    ),

    //Business dashboard routes
    CustomRoute(
      page: BusinessDashBoardView.page,
      path: '/businessDashboard',
      guards: [AuthGuard()],
      children: [
        AutoRoute(page: OwnedBusinessesView.page, path: 'home'),
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
      page: DetailsProfileView.page,
      path: '/seeProfile',
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: EditPreferencesView.page,
      path: '/editPreferences',
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: InviteFamilyView.page,
      path: '/inviteFamily',
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: MyFamilyMembersView.page,
      path: '/myFamilyMembers',
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
      page: OwnedBusinessDetailsView.page,
      path: '/ownedBusinessDetails',
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: PromotionDetailsView.page,
      path: '/promotionDetails',
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: OwnedPromotionDetailsView.page,
      path: '/ownedPromotionDetails',
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: BusinessAnalyticsView.page,
      path: '/businessAnalytics',
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    //Legal routes (no auth required)
    CustomRoute(
      page: TermsAndConditionsView.page,
      path: '/terms',
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
    CustomRoute(
      page: PrivacyPolicyView.page,
      path: '/privacy',
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),

    //Individual map hero routes
    CustomRoute(
      page: MapView.page,
      path: '/mapView',
      transitionsBuilder: TransitionsBuilders.slideLeft,
    ),
  ];
}
