import 'package:auto_route/auto_route.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@RoutePage()
class DashBoardView extends StatelessWidget {
  DashBoardView({Key? key}) : super(key: key);
  final locator = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    handleNotificationEvents(context);
    return AutoTabsScaffold(
      routes: [
        SearchView(),
        const FavoritesView(),
        const ProfileView(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return NavigationBar(
          animationDuration: const Duration(milliseconds: 500),
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Ionicons.search_outline),
              selectedIcon: Icon(Ionicons.search),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Icon(Ionicons.heart_outline),
              selectedIcon: Icon(Ionicons.heart),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: Icon(Ionicons.person_outline),
              selectedIcon: Icon(Ionicons.person),
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
