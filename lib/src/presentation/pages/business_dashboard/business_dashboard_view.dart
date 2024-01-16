import 'package:auto_route/auto_route.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';

@RoutePage()
class BusinessDashBoardView extends StatelessWidget {
  const BusinessDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: [
        OwnedBusinessesView(),
        const ProfileView(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return NavigationBar(
          animationDuration: const Duration(milliseconds: 500),
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Ionicons.business_outline),
              selectedIcon: Icon(Ionicons.business),
              label: 'Comercios',
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
}
