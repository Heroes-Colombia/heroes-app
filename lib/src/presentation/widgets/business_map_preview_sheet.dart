import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:ionicons/ionicons.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_details/business_details_cubit.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

/// Bottom sheet preview for businesses on map
/// Shows business info, action buttons, and active promotions
class BusinessMapPreviewSheet extends StatefulWidget {
  final String businessId;
  final String businessName;
  final String? categoryName;
  final String address;
  final String? phoneNumber;
  final double latitude;
  final double longitude;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const BusinessMapPreviewSheet({
    super.key,
    required this.businessId,
    required this.businessName,
    this.categoryName,
    required this.address,
    this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<BusinessMapPreviewSheet> createState() =>
      _BusinessMapPreviewSheetState();
}

class _BusinessMapPreviewSheetState extends State<BusinessMapPreviewSheet> {
  final locator = GetIt.instance;
  List<Promotion>? _promotions;
  bool _isLoadingPromotions = true;

  @override
  void initState() {
    super.initState();
    getBusinessPromotions();
    _checkIfFavorite();
    _trackBusinessView();
  }

  void _trackBusinessView() {
    final analyticsService = locator.get<AnalyticsService>();
    analyticsService.trackDashboardView(
      entityType: 'business',
      entityId: widget.businessId,
      businessId: widget.businessId,
      screen: 'map',
    );
  }

  void _checkIfFavorite() {
    context.read<BusinessDetailsCubit>().businessIsMarkedAsFavorite(
      widget.businessId,
    );
  }

  void _toggleFavorite() {
    // Call the parent callback which handles the favorite toggle
    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.35,
      maxChildSize: 0.55,
      snap: true,
      snapSizes: const [0.35, 0.55],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              _buildDragHandle(),
              _buildTopSection(theme),
              _buildActionButtons(theme),
              _buildPromotionsSection(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTopSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Name + Action Icons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.businessName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildActionIcons(theme),
            ],
          ),

          // Category (if available)
          if (widget.categoryName != null) ...[
            Text(
              widget.categoryName!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Address
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.address,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcons(ThemeData theme) {
    return BlocBuilder<BusinessDetailsCubit, BusinessDetailsState>(
      builder: (context, state) {
        final isFavorite = state.isFavourite;
        final isLoadingFavorite = state.favouriteIsLoading;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Favorite (always shown)
            SizedBox(
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
                        onPressed: _toggleFavorite,
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
            ),

            // Call (conditional)
            if (widget.phoneNumber != null &&
                widget.phoneNumber!.isNotEmpty) ...[
              const SizedBox(width: 4),
              IconButton.filledTonal(
                onPressed: () => callBusiness(widget.phoneNumber!),
                icon: const Icon(Ionicons.call_outline),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ],

            // WhatsApp (conditional)
            if (widget.phoneNumber != null &&
                widget.phoneNumber!.isNotEmpty) ...[
              const SizedBox(width: 4),
              IconButton.filledTonal(
                onPressed: () => openWhatsApp(widget.phoneNumber!),
                icon: const Icon(Ionicons.logo_whatsapp),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ],
            // close bottom sheet
            const SizedBox(width: 4),
            IconButton.filledTonal(
              onPressed: () => closeSheet(),
              icon: const Icon(Ionicons.close),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _navigateToBusiness,
              icon: const Icon(Icons.navigation),
              label: const Text('Navegar'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _viewBusinessDetails,
              icon: const Icon(Icons.business),
              label: const Text('Ver Negocio'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsSection(ThemeData theme) {
    if (_isLoadingPromotions) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_promotions == null || _promotions!.isEmpty) {
      return _buildNoPromotions(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.local_offer,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Promociones activas (${_promotions!.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _promotions!.length,
            itemBuilder: (context, index) {
              return _buildPromotionCard(_promotions![index], theme);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPromotionCard(Promotion promotion, ThemeData theme) {
    return InkWell(
      onTap: () => _openPromotionDetails(promotion),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promotion Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child:
                  promotion.featuredImage.isNotEmpty
                      ? Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Image.network(
                          promotion.featuredImage,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.local_offer, size: 32),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 100,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      )
                      : Container(
                        height: 100,
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
                              size: 40,
                              color: theme.colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${promotion.percentage}% OFF',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotion.title,
                    style: theme.textTheme.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Valido: ${_formatDate(promotion.expiredAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPromotions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'No hay promociones activas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper Methods

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  //this method is used to get the promotions of a business
  Future<void> getBusinessPromotions() async {
    try {
      final firestoreService = locator.get<FirestoreService>();
      final promotionsCollection =
          locator.get<AppConstants>().advertisementCollection;

      //We fetch the promotions from the database
      final rawPromotions = await firestoreService
          .readActiveDocumentsByCondition(
            promotionsCollection,
            'business_id',
            widget.businessId,
            999,
          );

      final promotions =
          rawPromotions.map((e) => Promotion.fromJson(e)).toList();

      //Then return the promotions
      setState(() {
        _promotions = promotions;
        _isLoadingPromotions = false;
      });
    } catch (e) {
      setState(() {
        _promotions = [];
        _isLoadingPromotions = false;
      });
    }
  }

  void _navigateToBusiness() async {
    // Track navigation click
    final analyticsService = locator.get<AnalyticsService>();
    analyticsService.trackDashboardClick(
      entityType: 'business',
      entityId: widget.businessId,
      businessId: widget.businessId,
      screen: 'map',
      metadata: {'link_type': 'navigation', 'link_value': 'maps'},
    );

    final texts =
        locator.get<AppConstants>().dashBoardTexts["businessDetailsView"]!;
    await locator.get<AppMethods>().navigateToLocation(
      latitude: widget.latitude,
      longitude: widget.longitude,
      address: widget.address,
      texts: texts,
      context: context,
    );
  }

  void openWhatsApp(String phoneNumber) {
    context.read<BusinessDetailsCubit>().openWhatsApp(
      phoneNumber,
      screen: 'map',
    );
  }

  void callBusiness(String phoneNumber) {
    context.read<BusinessDetailsCubit>().callBusiness(
      phoneNumber,
      screen: 'map',
    );
  }

  void _viewBusinessDetails() {
    // Track view business details click
    final analyticsService = locator.get<AnalyticsService>();
    analyticsService.trackDashboardClick(
      entityType: 'business',
      entityId: widget.businessId,
      businessId: widget.businessId,
      screen: 'map',
      metadata: {
        'link_type': 'viewBusinessDetails',
        'link_value': widget.businessId,
      },
    );

    closeSheet();
    context.router.push(BusinessDetailsView(businessId: widget.businessId));
  }

  void closeSheet() {
    Navigator.pop(context);
  }

  void _openPromotionDetails(Promotion promotion) {
    // Track promotion view
    final analyticsService = locator.get<AnalyticsService>();
    analyticsService.trackDashboardView(
      entityType: 'promotion',
      entityId: promotion.documentId ?? '',
      businessId: widget.businessId,
      screen: 'map',
    );

    closeSheet();
    AutoRouter.of(context).push(
      PromotionDetailsView(
        promotionId: promotion.documentId ?? '',
        promotion: promotion,
      ),
    );
  }
}
