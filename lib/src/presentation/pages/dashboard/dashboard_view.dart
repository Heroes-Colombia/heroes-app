import 'package:auto_route/auto_route.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';

@RoutePage()
class DashBoardView extends StatelessWidget {
  const DashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: [
        const SearchView(),
        const FavoritesView(),
        ProfileView(),
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
}
