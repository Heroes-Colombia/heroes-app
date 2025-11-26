import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:heroes_app/src/presentation/cubits/promotion/promotion_details_cubit.dart';
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
  String? _businessName;
  bool _isLoadingBusinessName = false;

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
      _fetchBusinessName(widget.promotion!.businessId);
    }
  }

  Future<void> _fetchBusinessName(String businessId) async {
    setState(() {
      _isLoadingBusinessName = true;
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
          _businessName = business.name;
          _isLoadingBusinessName = false;
        });
      }
    } catch (e) {
      log('Error fetching business name: $e');
      setState(() {
        _isLoadingBusinessName = false;
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
                      // Fetch business name when promotion is loaded
                      if (_businessName == null && !_isLoadingBusinessName) {
                        _fetchBusinessName(state.promotion!.businessId);
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
        SliverAppBar.large(
          title: Text(
            texts['title']!,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
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
                // Image section - show image or gradient placeholder
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: promotion.featuredImage.isNotEmpty
                        ? Image.network(
                            promotion.featuredImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            // Performance optimizations
                            cacheWidth: 800,
                            cacheHeight: 600,
                            filterQuality: FilterQuality.medium,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Imagen no disponible',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant
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
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '${promotion.percentage}% OFF',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Promoción Especial',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer
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
                const SizedBox(height: 12),
                // Favorite button
                BlocBuilder<PromotionDetailsCubit, PromotionDetailsState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: 40,
                      child:
                          state.favouriteIsLoading
                              ? _loadingHeart(theme)
                              : IconButton.filledTonal(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    theme.colorScheme.background,
                                  ),
                                ),
                                onPressed: () {
                                  _setPromotionAsFavourite(promotion);
                                },
                                icon: Icon(
                                  state.isFavourite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      state.isFavourite
                                          ? theme.colorScheme.primary
                                          : null,
                                ),
                              ),
                    );
                  },
                ),
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
              top: 24,
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
        sectionTitle(texts['instructions-title']!, theme),
        sectionBody(theme, promotion.instructions),
        divider(theme),
        sectionDouble(
          theme,
          texts['discount-title']!,
          "${promotion.percentage}%",
        ),
        sectionDouble(
          theme,
          texts['expiration-title']!,
          getExpirationDate(promotion.expiredAt),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        // Button to navigate to business
        businessNavigationButton(theme, promotion),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
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

  SliverToBoxAdapter sectionDouble(ThemeData theme, title, text) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: theme.textTheme.labelLarge!.fontSize,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: theme.textTheme.labelLarge!.fontSize,
                fontWeight: theme.textTheme.bodySmall!.fontWeight,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ],
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

  SliverToBoxAdapter businessNavigationButton(
    ThemeData theme,
    Promotion promotion,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: InkWell(
          onTap: () {
            AutoRouter.of(
              context,
            ).push(BusinessDetailsView(businessId: promotion.businessId));
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.store,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isLoadingBusinessName
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            )
                          : Text(
                              _businessName ?? 'Ver negocio',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: theme.textTheme.titleSmall!.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      const SizedBox(height: 2),
                      Text(
                        'Conoce más sobre este negocio',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8),
                          fontSize: theme.textTheme.bodySmall!.fontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getExpirationDate(DateTime expirationDay) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(expirationDay);
    return formattedDate;
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

    // CRITICAL FIX: Add null safety check with logging
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

  // Loading heart widget
  Widget _loadingHeart(ThemeData theme) {
    return SizedBox(
      width: 40,
      child: Stack(
        children: [
          IconButton.filledTonal(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                theme.colorScheme.background,
              ),
            ),
            onPressed: null,
            icon: const Icon(Icons.favorite_border),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
