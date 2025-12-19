import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroes_app/src/presentation/cubits/profile/profile_cubit.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:heroes_app/src/domain/services/onboarding_service.dart';

@RoutePage()
class DashBoardView extends StatefulWidget {
  const DashBoardView({super.key});

  @override
  State<DashBoardView> createState() => _DashBoardViewState();
}

class _DashBoardViewState extends State<DashBoardView> {
  final locator = GetIt.instance;

  // Showcase keys for bottom navigation
  final GlobalKey homeNavKey = GlobalKey();
  final GlobalKey favoritesNavKey = GlobalKey();
  final GlobalKey profileNavKey = GlobalKey();

  // Showcase key for search view content
  final GlobalKey promotionsKey = GlobalKey();

  // Track if showcase has been started to prevent multiple triggers
  bool _showcaseStarted = false;

  @override
  void initState() {
    super.initState();
    // Load user profile data when dashboard initializes
    context.read<ProfileCubit>().getProfileInfo();
  }

  void _checkAndShowShowcase(BuildContext context) {
    final onboardingService = locator.get<OnboardingService>();

    if (!onboardingService.hasSeenShowcase && !_showcaseStarted) {
      _showcaseStarted = true;
      // Delay to ensure all widgets are built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only showcase visible elements - no scrolling required
        ShowCaseWidget.of(context).startShowCase([
          promotionsKey, // 1. Featured promotions carousel
          homeNavKey, // 2. Bottom nav - Home
          favoritesNavKey, // 3. Bottom nav - Favorites
          profileNavKey, // 4. Bottom nav - Profile
        ]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    handleNotificationEvents(context);
    return ShowCaseWidget(
      onFinish: () {
        // Mark showcase as seen when user finishes the tutorial
        locator.get<OnboardingService>().setShowcaseShown();
      },
      builder: (showcaseContext) {
        // Check if showcase should be shown after the ShowCaseWidget is built
        _checkAndShowShowcase(showcaseContext);

        return AutoTabsScaffold(
          routes: [
            SearchView(promotionsKey: promotionsKey),
            const FavoritesView(),
            const ProfileView(),
          ],
          bottomNavigationBuilder: (context, tabsRouter) {
            return NavigationBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              animationDuration: const Duration(milliseconds: 500),
              selectedIndex: tabsRouter.activeIndex,
              onDestinationSelected: tabsRouter.setActiveIndex,
              destinations: [
                NavigationDestination(
                  icon: Showcase(
                    key: homeNavKey,
                    description:
                        'Pantalla de inicio donde puedes explorar promociones y negocios.',
                    child: SvgPicture.asset(
                      'assets/icon/home.svg',
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Showcase(
                    key: favoritesNavKey,
                    description:
                        'Guarda y accede rápidamente a tus negocios y promociones favoritas.',
                    child: SvgPicture.asset(
                      'assets/icon/favourite.svg',
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  label: 'Favoritos',
                ),
                NavigationDestination(
                  icon: Showcase(
                    key: profileNavKey,
                    description:
                        'Gestiona tu perfil, configuración y preferencias de la aplicación.',
                    child: SvgPicture.asset(
                      'assets/icon/profile.svg',
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  label: 'Perfil',
                ),
              ],
            );
          },
        );
      },
    );
  }

  //Methods

  //When the app is ready and the user is logged in, the app will handle the notification
  Future<void> handleNotificationEvents(BuildContext context) async {
    /*
      If the user tap on notification when the app is terminated, the app will open
      and handle the notification if the user is logged in.
     */
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) return;
      locator.get<AppMethods>().handleRemoteMessage(message, context);
    });

    //This will handle the notification tap when the app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      locator.get<AppMethods>().handleRemoteMessage(message, context);
    });
  }
}
