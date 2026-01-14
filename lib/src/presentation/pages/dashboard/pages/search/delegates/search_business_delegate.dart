import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_search_results/business_search_resutls_cubit.dart';
import 'package:ionicons/ionicons.dart';

class SearchBusinessDelegate extends SearchDelegate {
  final locator = GetIt.instance;
  /*
   This variable is used to prevent the buildResults method from being called
   when the user navigate to the business details page and then returns back to
   the search page.
  */
  bool hasNavigated = false;

  @override
  get searchFieldLabel =>
      locator<AppConstants>().dashBoardTexts["searchView"]!["search-business"];

  @override
  ThemeData appBarTheme(BuildContext context) {
    var theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurfaceVariant),
        actionsIconTheme: IconThemeData(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      query.isNotEmpty
          ? IconButton(
            onPressed: () {
              //Show suggestions again
              showSuggestions(context);
              //Focus the text field using the widget focus method
              query = "";
            },
            icon: const Icon(Ionicons.close),
          )
          : Container(),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Ionicons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (!hasNavigated) {
      context.read<BusinessSearchResutlsCubit>().searchBusinesses(query);
    }

    return BlocBuilder<BusinessSearchResutlsCubit, BusinessSearchResutlsState>(
      builder: (context, state) {
        if (state.isSearching) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.businesses.isEmpty && state.promotions.isEmpty) {
          return Center(
            child: Text(
              locator<AppConstants>()
                  .dashBoardTexts["searchView"]!["no-results"]!,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          );
        } else {
          // Build a combined list with section headers
          return ListView.builder(
            itemCount: _calculateTotalItems(state),
            itemBuilder: (context, index) {
              return _buildListItem(context, state, index);
            },
          );
        }
      },
    );
  }

  // Calculate total items including section headers
  int _calculateTotalItems(BusinessSearchResutlsState state) {
    int count = 0;

    // Add businesses section
    if (state.businesses.isNotEmpty) {
      count += 1; // Header
      count += state.businesses.length;
    }

    // Add promotions section
    if (state.promotions.isNotEmpty) {
      count += 1; // Header
      count += state.promotions.length;
    }

    return count;
  }

  // Build individual list items with section headers
  Widget _buildListItem(
    BuildContext context,
    BusinessSearchResutlsState state,
    int index,
  ) {
    int currentIndex = index;

    // Businesses section
    if (state.businesses.isNotEmpty) {
      // Businesses header
      if (currentIndex == 0) {
        return _buildSectionHeader(
          context,
          "Negocios",
          state.businesses.length,
        );
      }
      currentIndex--;

      // Business items
      if (currentIndex < state.businesses.length) {
        final business = state.businesses[currentIndex];
        _trackBusinessImpression(business.id, currentIndex);
        return _buildBusinessTile(context, business);
      }
      currentIndex -= state.businesses.length;
    }

    // Promotions section
    if (state.promotions.isNotEmpty) {
      // Promotions header
      if (currentIndex == 0) {
        return _buildSectionHeader(
          context,
          "Promociones",
          state.promotions.length,
        );
      }
      currentIndex--;

      // Promotion items
      if (currentIndex < state.promotions.length) {
        final promotion = state.promotions[currentIndex];
        _trackPromotionImpression(
          promotion.documentId ?? '',
          promotion.businessId,
          currentIndex,
        );
        return _buildPromotionTile(context, promotion);
      }
    }

    return const SizedBox.shrink();
  }

  // Build section header widget
  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // Build business list tile
  Widget _buildBusinessTile(BuildContext context, var business) {
    return ListTile(
      leading: Icon(
        Ionicons.storefront_outline,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        business.name,
        style: Theme.of(context).textTheme.labelLarge,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: const Icon(Ionicons.chevron_forward),
      onTap: () {
        hasNavigated = true;
        AutoRouter.of(context).push(
          BusinessDetailsView(businessId: business.id),
        );
      },
    );
  }

  // Build promotion list tile
  Widget _buildPromotionTile(BuildContext context, var promotion) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${promotion.percentage}%',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
      title: Text(
        promotion.title,
        style: Theme.of(context).textTheme.labelLarge,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: promotion.businessName != null
          ? Text(
              promotion.businessName!,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          : null,
      trailing: const Icon(Ionicons.chevron_forward),
      onTap: () {
        hasNavigated = true;
        AutoRouter.of(context).push(
          PromotionDetailsView(
            promotionId: promotion.documentId ?? '',
            promotion: promotion,
          ),
        );
      },
    );
  }

  // V2: Track promotion impression in search results
  void _trackPromotionImpression(
    String promotionId,
    String businessId,
    int position,
  ) {
    final analyticsService = GetIt.instance.get<AnalyticsService>();
    analyticsService.trackDashboardImpression(
      entityType: 'promotion',
      entityId: promotionId,
      businessId: businessId,
      screen: 'search_results',
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var theme = Theme.of(context);
    hasNavigated = false;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Center(
          child: Icon(
            Ionicons.search,
            size: 100,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }

  // V2: Track business impression in search results
  void _trackBusinessImpression(String businessId, int position) {
    final analyticsService = GetIt.instance.get<AnalyticsService>();
    analyticsService.trackDashboardImpression(
      entityType: 'business',
      entityId: businessId,
      businessId: businessId,
      screen: 'search_results',
    );
  }
}
