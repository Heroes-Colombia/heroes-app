import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroes_app/src/presentation/cubits/profile/profile_cubit.dart';

@RoutePage()
class DashBoardView extends StatefulWidget {
  const DashBoardView({super.key});

  @override
  State<DashBoardView> createState() => _DashBoardViewState();
}

class _DashBoardViewState extends State<DashBoardView> {
  final locator = GetIt.instance;

  @override
  void initState() {
    super.initState();
    // Load user profile data when dashboard initializes
    context.read<ProfileCubit>().getProfileInfo();
  }

  @override
  Widget build(BuildContext context) {
    handleNotificationEvents(context);
    return AutoTabsScaffold(
      routes: [SearchView(), const FavoritesView(), const ProfileView()],
      bottomNavigationBuilder: (context, tabsRouter) {
        return NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          animationDuration: const Duration(milliseconds: 500),
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: [
            NavigationDestination(
              icon: SvgPicture.asset(
                'assets/icon/home.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                'assets/icon/favourite.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                'assets/icon/profile.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Perfil',
            ),
          ],
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
