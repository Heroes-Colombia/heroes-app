import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroes_app/src/presentation/cubits/profile/profile_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/in_app_message_modal.dart';
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

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _inAppSubscription;
  // Tracks the last campaign shown so we don't repeat it in the same session
  String? _lastShownCampaignId;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getProfileInfo();
    _listenForInAppMessages();
  }

  @override
  void dispose() {
    _inAppSubscription?.cancel();
    super.dispose();
  }

  void _listenForInAppMessages() {
    _inAppSubscription = FirebaseFirestore.instance
        .collection('active_inapp_messages')
        .doc('current')
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || !mounted) return;

      final data = snapshot.data()!;
      final active = data['active'] as bool? ?? false;
      final campaignId = data['campaign_id'] as String?;
      final expiresAt = data['expires_at'] as Timestamp?;

      if (!active) return;
      if (campaignId == null || campaignId == _lastShownCampaignId) return;
      if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) return;

      _lastShownCampaignId = campaignId;

      final ctx = context;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!ctx.mounted) return;
        _showInAppMessage(ctx, data);
      });
    });
  }

  void _showInAppMessage(BuildContext ctx, Map<String, dynamic> data) {
    final imageUrl = data['image_url'] as String?;
    final buttonAction = data['button_action'] as String? ?? '';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InAppMessageModal(
        title: data['title'] as String? ?? '',
        body: data['body'] as String? ?? '',
        imageUrl: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null,
        buttonText: data['button_text'] as String? ?? 'Ver promociones',
        onAction: _resolveAction(ctx, buttonAction),
      ),
    );
  }

  /// Parses a `heroescolombia://` deep-link and returns the matching navigation
  /// callback, or null if no additional navigation is needed.
  ///
  /// Supported actions:
  ///   heroescolombia://promotions          → home tab (already visible)
  ///   heroescolombia://business?id=`<id>`    → business detail page
  ///   heroescolombia://promotion?id=`<id>`   → promotion detail page
  VoidCallback? _resolveAction(BuildContext ctx, String action) {
    if (action.isEmpty) return null;

    final uri = Uri.tryParse(action);
    if (uri == null) return null;

    final path = uri.host; // e.g. "promotions", "business", "promotion"

    switch (path) {
      case 'promotions':
        // User is already on the dashboard — no further navigation needed.
        return null;

      case 'business':
        final id = uri.queryParameters['id'];
        if (id == null || id.isEmpty) return null;
        return () => AutoRouter.of(ctx).push(BusinessDetailsView(businessId: id));

      case 'promotion':
        final id = uri.queryParameters['id'];
        if (id == null || id.isEmpty) return null;
        return () => AutoRouter.of(ctx).push(
              PromotionDetailsView(promotion: null, promotionId: id),
            );

      default:
        return null;
    }
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
