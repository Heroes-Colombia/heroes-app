import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_details/business_details_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/promotion/promotion_details_cubit.dart';
import 'package:ionicons/ionicons.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

@RoutePage()
class PromotionDetailsView extends StatefulWidget {
  final Promotion? promotion;
  final String? promotionId;
  const PromotionDetailsView({
    super.key,
    required this.promotion,
    required this.promotionId,
  });

  @override
  State<PromotionDetailsView> createState() => _PromotionDetailsViewState();
}

class _PromotionDetailsViewState extends State<PromotionDetailsView> {
  Business? _business;
  bool _isLoadingBusiness = false;

  @override
  void initState() {
    super.initState();
    if (widget.promotion == null && widget.promotionId != null) {
      context.read<PromotionDetailsCubit>().getPromotionDetails(
        widget.promotionId!,
      );
      context.read<PromotionDetailsCubit>().promotionIsMarkedAsFavorite(
        widget.promotionId!,
      );
    } else if (widget.promotion != null &&
        widget.promotion!.documentId != null) {
      context.read<PromotionDetailsCubit>().promotionIsMarkedAsFavorite(
        widget.promotion!.documentId!,
      );
      _fetchBusinessData(widget.promotion!.businessId);
    }
  }

  Future<void> _fetchBusinessData(String businessId) async {
    setState(() {
      _isLoadingBusiness = true;
    });

    try {
      final locator = GetIt.instance;
      final firestoreService = locator.get<FirestoreService>();
      final businessCollection = locator.get<AppConstants>().businessCollection;

      final rawBusiness = await firestoreService.readDocumentByDocId(
        businessCollection,
        businessId,
      );

      if (rawBusiness != null) {
        final business = Business.fromJson(rawBusiness);
        setState(() {
          _business = business;
          _isLoadingBusiness = false;
        });
      }
    } catch (e) {
      log('Error fetching business data: $e');
      setState(() {
        _isLoadingBusiness = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts =
        locator.get<AppConstants>().dashBoardTexts['promotionDetailsView']!;

    return Scaffold(
      body:
          widget.promotion != null
              ? promotionBodyWidget(texts, theme, widget.promotion!)
              : BlocBuilder<PromotionDetailsCubit, PromotionDetailsState>(
                builder: (context, state) {
                  switch (state.status) {
                    case BusinessViewCubitStatus.initial:
                      return const Center(child: CircularProgressIndicator());
                    case BusinessViewCubitStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case BusinessViewCubitStatus.success:
                      // Fetch business data when promotion is loaded
                      if (_business == null && !_isLoadingBusiness) {
                        _fetchBusinessData(state.promotion!.businessId);
                      }
                      return promotionBodyWidget(
                        texts,
                        theme,
                        state.promotion!,
                      );
                    case BusinessViewCubitStatus.error:
                      return const Center(child: Text('Error'));

                    default:
                      return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
    );
  }

  CustomScrollView promotionBodyWidget(
    Map<String, String> texts,
    ThemeData theme,
    Promotion promotion,
  ) {
    // Track promotion view analytics
    _trackPromotionView(promotion);

    return CustomScrollView(
      slivers: [
        SliverAppBar.medium(
          title: Text(
            texts['title']!,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: theme.textTheme.headlineSmall!.fontSize,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 12,
              top: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Image with discount badge overlay
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child:
                            promotion.featuredImage.isNotEmpty
                                ? Image.network(
                                  promotion.featuredImage,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  // Performance optimizations
                                  cacheWidth: 800,
                                  cacheHeight: 600,
                                  filterQuality: FilterQuality.medium,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color:
                                          theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                        color:
                                            theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported,
                                            size: 64,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withValues(alpha: 0.5),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Imagen no disponible',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                      .withValues(alpha: 0.7),
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        theme.colorScheme.primaryContainer,
                                        theme.colorScheme.secondaryContainer,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.local_offer,
                                        size: 80,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer
                                            .withValues(alpha: 0.8),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '${promotion.percentage}% OFF',
                                        style: TextStyle(
                                          color:
                                              theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Promoción Especial',
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer
                                              .withValues(alpha: 0.7),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ),
                    // Discount badge overlay (top-right)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${promotion.percentage}% OFF',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action buttons row with favorite icon
                _buildActionButtons(theme, promotion),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 12,
              top: 5,
            ),
            child: Text(
              promotion.title,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
                fontSize: theme.textTheme.bodyLarge!.fontSize,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        divider(theme),
        sectionTitle(texts['description-title']!, theme),
        sectionBody(theme, promotion.description),
        if (promotion.instructions.isNotEmpty) ...[
          sectionTitle(texts['instructions-title']!, theme),
          sectionBody(theme, promotion.instructions),
        ],
        SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  SliverToBoxAdapter sectionTitle(String text, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: theme.textTheme.labelLarge!.fontSize,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter sectionBody(ThemeData theme, text) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Text(
          text,
          style: TextStyle(
            fontSize: theme.textTheme.labelLarge!.fontSize,
            fontWeight: theme.textTheme.bodySmall!.fontWeight,
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter divider(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
        child: Divider(
          height: 1,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  // Build action buttons row (Navigate, View Business, and action icons)
  Widget _buildActionButtons(ThemeData theme, Promotion promotion) {
    final hasPhone =
        _business?.phoneNumber != null && _business!.phoneNumber.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Navigation and View Business buttons
          Row(
            children: [
              // Navigate button (only for physical businesses)
              if (hasPhone) ...[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openWhatsApp(),
                    icon: const Icon(Ionicons.logo_whatsapp),
                    label: const Text('Redimir'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Call button (conditional)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callBusiness(),
                    icon: const Icon(Ionicons.call_outline),
                    label: const Text('Llamar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _viewBusinessDetails(promotion),
                    icon: const Icon(Icons.business),
                    label: const Text('Ver negocio'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Action icons row (Favorite, Call, WhatsApp)
          _buildActionIcons(theme, promotion),
        ],
      ),
    );
  }

  // Build action icons (Favorite, Call, WhatsApp)
  Widget _buildActionIcons(ThemeData theme, Promotion promotion) {
    final hasAddress = _business?.address != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // View Business button
        IconButton.filledTonal(
          onPressed: () => _viewBusinessDetails(promotion),
          icon: const Icon(Icons.business),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Navigation button (conditional)
        if (hasAddress) ...[
          IconButton.filledTonal(
            onPressed: () => _navigateToBusiness(theme),
            icon: const Icon(Icons.navigation),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        // Favorite icon
        BlocBuilder<PromotionDetailsCubit, PromotionDetailsState>(
          builder: (context, state) {
            final isFavorite = state.isFavourite;
            final isLoadingFavorite = state.favouriteIsLoading;

            return SizedBox(
              width: 40,
              height: 40,
              child:
                  isLoadingFavorite
                      ? Stack(
                        children: [
                          IconButton.filledTonal(
                            onPressed: null,
                            icon: const Icon(Icons.favorite_border),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : IconButton.filledTonal(
                        onPressed: () => _setPromotionAsFavourite(promotion),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? theme.colorScheme.primary : null,
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
            );
          },
        ),
      ],
    );
  }

  // Navigate to business location
  void _navigateToBusiness(ThemeData theme) async {
    if (_business == null) return;

    final locator = GetIt.instance;
    final texts =
        locator.get<AppConstants>().dashBoardTexts["businessDetailsView"]!;

    // Track navigation click
    final analyticsService = locator.get<AnalyticsService>();
    analyticsService.trackDashboardClick(
      entityType: 'business',
      entityId: _business!.ownerUid,
      businessId: _business!.ownerUid,
      screen: 'promotion_details',
      metadata: {'link_type': 'navigation', 'link_value': 'maps'},
    );

    await locator.get<AppMethods>().navigateToLocation(
      latitude: _business!.location.latitude,
      longitude: _business!.location.longitude,
      address: _business!.address,
      texts: texts,
      context: context,
    );
  }

  // View business details
  void _viewBusinessDetails(Promotion promotion) {
    // Track view business details click
    final analyticsService = GetIt.instance.get<AnalyticsService>();
    analyticsService.trackDashboardClick(
      entityType: 'business',
      entityId: promotion.businessId,
      businessId: promotion.businessId,
      screen: 'promotion_details',
      metadata: {
        'link_type': 'viewBusinessDetails',
        'link_value': promotion.businessId,
      },
    );

    AutoRouter.of(
      context,
    ).push(BusinessDetailsView(businessId: promotion.businessId));
  }

  // Call business
  void _callBusiness() {
    if (_business?.phoneNumber == null) return;
    context.read<BusinessDetailsCubit>().callBusiness(
      _business!.phoneNumber,
      screen: 'promotion_details',
    );
  }

  // Open WhatsApp
  void _openWhatsApp() {
    if (_business?.phoneNumber == null) return;
    context.read<BusinessDetailsCubit>().openWhatsApp(
      _business!.phoneNumber,
      screen: 'promotion_details',
    );
  }

  // Analytics tracking method - V2 Dashboard-compatible
  void _trackPromotionView(Promotion promotion) {
    final analyticsService = GetIt.instance.get<AnalyticsService>();

    // V2: Track using Dashboard-compatible method
    analyticsService.trackDashboardView(
      entityType: 'promotion',
      entityId: promotion.documentId ?? 'unknown',
      businessId: promotion.businessId,
      screen: 'promotion_details',
    );
  }

  // Set promotion as favourite
  void _setPromotionAsFavourite(Promotion promotion) {
    final promotionId = promotion.documentId ?? widget.promotionId;

    if (promotionId == null) {
      log('Warning: Cannot favorite promotion - missing ID');
      return;
    }

    // Track analytics when favoriting
    final state = context.read<PromotionDetailsCubit>().state;
    final willBeFavorite = !state.isFavourite;

    if (willBeFavorite) {
      _trackPromotionFavorite(promotion);
    }

    context.read<PromotionDetailsCubit>().setPromotionAsFavourite(promotionId);
  }

  // Track promotion favorite analytics
  void _trackPromotionFavorite(Promotion promotion) {
    final analyticsService = GetIt.instance.get<AnalyticsService>();
    analyticsService.trackDashboardSave(
      entityType: 'promotion',
      entityId: promotion.documentId ?? 'unknown',
      businessId: promotion.businessId,
    );
  }
}
