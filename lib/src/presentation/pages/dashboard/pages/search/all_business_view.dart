import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:heroes_app/src/domain/models/business_filter.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/presentation/cubits/business/all_business/all_business_cubit.dart';
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/delegates/categories_header_delegate.dart';
import 'package:heroes_app/src/presentation/widgets/horizontal_card_widget.dart';
import 'package:heroes_app/src/presentation/widgets/searchable_category_selector.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class AllBusinessView extends StatefulWidget {
  final String? initialCategoryId;
  final BusinessFilter? filter;
  const AllBusinessView({super.key, this.initialCategoryId, this.filter});

  @override
  State<AllBusinessView> createState() => _AllBusinessViewState();
}

class _AllBusinessViewState extends State<AllBusinessView> {
  @override
  void initState() {
    super.initState();

    if (context.read<AllBusinessCubit>().state.categories.isEmpty) {
      context.read<AllBusinessCubit>().getBusinessCategories();
    }

    // Set the initial filter if provided, otherwise use the initialCategoryId
    if (widget.filter != null) {
      context.read<AllBusinessCubit>().setInitialFilter(widget.filter);
    } else if (widget.initialCategoryId != null) {
      context.read<AllBusinessCubit>().setSelectedCategoryId(
        widget.initialCategoryId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var locator = GetIt.instance;
    var theme = Theme.of(context);
    var texts = locator<AppConstants>().dashBoardTexts["allBusinessView"]!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<AllBusinessCubit>().handleOnPop(context);
        }
      },

      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: BlocBuilder<AllBusinessCubit, AllBusinessState>(
          builder: (context, state) {
            switch (state.status) {
              case BusinessViewCubitStatus.initial:
                return loadingView(theme, texts);
              case BusinessViewCubitStatus.loading:
                getAllBusinesses(context);
                return loadingView(theme, texts);
              case BusinessViewCubitStatus.success:
                return succesView(theme, texts, state.businesses, context);
              case BusinessViewCubitStatus.error:
                return errorView(theme, texts, context);
              default:
                return errorView(theme, texts, context);
            }
          },
        ),
      ),
    );
  }

  //View state methods
  CustomScrollView loadingView(ThemeData theme, texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(
            texts["title"],
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              fontSize: theme.textTheme.headlineSmall!.fontSize,
            ),
          ),
        ),
        if (context.read<AllBusinessCubit>().state.categories.isNotEmpty)
          SliverPersistentHeader(
            pinned: true,
            delegate: PersistentHeader(
              child: Container(
                color: theme.colorScheme.background,
                height: 100,
                width: double.infinity,
                child: categoriesDropDown(theme, texts),
              ),
            ),
          ),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  CustomScrollView errorView(ThemeData theme, texts, BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(
            texts["error-title"],
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              fontSize: theme.textTheme.headlineSmall!.fontSize,
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  texts["error-content"],
                  style: theme.textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Ionicons.refresh),
                  onPressed: () => getAllBusinesses(context),
                  label: Text(texts["error-button"]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  CustomScrollView succesView(
    ThemeData theme,
    texts,
    List<ListableBusiness> businesses,
    BuildContext context,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(
            texts["title"],
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              fontSize: theme.textTheme.headlineSmall!.fontSize,
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: PersistentHeader(
            child: Container(
              color: theme.colorScheme.background,
              height: 100,
              width: double.infinity,
              child: categoriesDropDown(theme, texts),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          sliver: businessGrid(businesses, theme, texts),
        ),
      ],
    );
  }

  //Widgets
  Widget businessGrid(List<ListableBusiness> businesses, theme, texts) {
    return businesses.isNotEmpty
        ? SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 185,
          ),
          itemCount: businesses.length,
          itemBuilder: (context, index) {
            _trackBusinessImpression(businesses[index].id);
            return HorizontalCard(
              isOnGrid: true,
              image: businesses[index].featuredImage,
              title: businesses[index].name,
              id: businesses[index].id,
              category: null,
              callback: () {
                AutoRouter.of(
                  context,
                ).push(BusinessDetailsView(businessId: businesses[index].id));
              },
            );
          },
        )
        : SliverFillRemaining(
          child: Center(
            child: Text(
              texts["empty-content"],
              style: theme.textTheme.labelLarge,
            ),
          ),
        );
  }

  Widget categoriesDropDown(ThemeData theme, texts) {
    return BlocBuilder<AllBusinessCubit, AllBusinessState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SearchableCategorySelector(
            categories: state.categories,
            selectedCategoryId: state.selectedCategoryId,
            onCategorySelected: (categoryId) {
              context.read<AllBusinessCubit>().setSelectedCategoryId(categoryId ?? '');
            },
            allCategoriesText: texts["all-categories"],
          ),
        );
      },
    );
  }

  //Methods
  void getAllBusinesses(BuildContext context) {
    context.read<AllBusinessCubit>().getBusinesses();
  }

  // V2: Track business impression in search results
  void _trackBusinessImpression(String businessId) {
    final analyticsService = GetIt.instance.get<AnalyticsService>();
    analyticsService.trackDashboardImpression(
      entityType: 'business',
      entityId: businessId,
      businessId: businessId,
      screen: 'home_feed',
    );
  }
}
