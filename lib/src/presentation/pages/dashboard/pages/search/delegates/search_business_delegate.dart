import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        // Track search analytics when results are loaded
        if (!state.isSearching && !hasNavigated && query.isNotEmpty) {
          _trackSearchAnalytics(query, state.businesses.length);
        }

        if (state.isSearching) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.businesses.isEmpty) {
          return Center(
            child: Text(
              locator<AppConstants>()
                  .dashBoardTexts["searchView"]!["no-results"]!,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          );
        } else {
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: state.businesses.length,
            itemBuilder: (context, index) {
              var business = state.businesses[index];

              // V2: Track impression for each business in search results
              _trackBusinessImpression(business.id, index);

              return ListTile(
                leading: Icon(
                  Ionicons.storefront_outline,
                  color: Theme.of(context).colorScheme.onBackground,
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
                  AutoRouter.of(
                    context,
                  ).push(BusinessDetailsView(businessId: business.id));
                },
              );
            },
          );
        }
      },
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
          color: Theme.of(context).colorScheme.background,
        ),
        child: Center(
          child: Icon(
            Ionicons.search,
            size: 100,
            color: theme.colorScheme.surfaceVariant,
          ),
        ),
      ),
    );
  }

  // Track search analytics
  void _trackSearchAnalytics(String searchQuery, int resultsCount) {
    final analyticsService = GetIt.instance.get<AnalyticsService>();
    analyticsService.trackBusinessSearch(
      searchTerm: searchQuery,
      resultsCount: resultsCount,
      userLocation: null, // You might want to get actual user location as GeoPoint
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
