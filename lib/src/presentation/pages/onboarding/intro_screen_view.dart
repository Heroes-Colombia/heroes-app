import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:heroes_app/src/domain/services/onboarding_service.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';

@RoutePage()
class IntroScreenView extends StatelessWidget {
  const IntroScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onboardingService = GetIt.instance<OnboardingService>();

    return IntroductionScreen(
      pages: [
        // Page 1: Welcome
        PageViewModel(
          title: "Bienvenido a Héroes Colombia",
          body: "Descubre promociones exclusivas y apoya a negocios locales que valoran tu servicio.",
          image: _buildImage(
            context,
            icon: Icons.military_tech,
            color: theme.colorScheme.primary,
          ),
          decoration: _getPageDecoration(theme),
        ),
        // Page 2: Discover Promotions
        PageViewModel(
          title: "Encuentra Ofertas Destacadas",
          body: "Accede a descuentos especiales en restaurantes, tiendas, servicios y mucho más.",
          image: _buildImage(
            context,
            icon: Icons.local_offer,
            color: theme.colorScheme.secondary,
          ),
          decoration: _getPageDecoration(theme),
        ),
        // Page 3: Save Favorites
        PageViewModel(
          title: "Guarda tus Favoritos",
          body: "Mantén tus negocios y promociones preferidas siempre a mano para acceder rápidamente.",
          image: _buildImage(
            context,
            icon: Icons.favorite,
            color: Colors.red,
          ),
          decoration: _getPageDecoration(theme),
        ),
        // Page 4: Explore Map
        PageViewModel(
          title: "Explora el Mapa",
          body: "Encuentra negocios físicos cerca de ti y descubre promociones en tu área.",
          image: _buildImage(
            context,
            icon: Icons.map,
            color: Colors.green,
          ),
          decoration: _getPageDecoration(theme),
        ),
      ],
      onDone: () async {
        await onboardingService.setIntroScreenShown();
        if (context.mounted) {
          AutoRouter.of(context).replaceAll([const DashBoardView()]);
        }
      },
      onSkip: () async {
        await onboardingService.setIntroScreenShown();
        if (context.mounted) {
          AutoRouter.of(context).replaceAll([const DashBoardView()]);
        }
      },
      showSkipButton: true,
      skip: Text(
        'Saltar',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
      next: Icon(
        Icons.arrow_forward,
        color: theme.colorScheme.primary,
      ),
      done: Text(
        'Comenzar',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: theme.colorScheme.primary,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      controlsMargin: const EdgeInsets.all(16),
      globalBackgroundColor: theme.colorScheme.surface,
    );
  }

  Widget _buildImage(
    BuildContext context, {
    required IconData icon,
    required Color color,
  }) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 100,
          color: color,
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration(ThemeData theme) {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 18.0,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      imagePadding: const EdgeInsets.only(top: 60),
      pageColor: theme.colorScheme.surface,
      contentMargin: const EdgeInsets.symmetric(horizontal: 16),
      bodyPadding: const EdgeInsets.all(16),
    );
  }
}
