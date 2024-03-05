import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:flutter_svg/svg.dart';

@RoutePage()
class BusinessDashBoardView extends StatelessWidget {
  const BusinessDashBoardView({super.key});

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
              label: 'Comercios',
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
}
