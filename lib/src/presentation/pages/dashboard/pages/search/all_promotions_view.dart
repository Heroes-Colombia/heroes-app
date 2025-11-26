import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:heroes_app/src/domain/models/promotion_filter.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/presentation/cubits/promotion/all_promotions/all_promotions_cubit.dart';
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/delegates/categories_header_delegate.dart';
import 'package:heroes_app/src/presentation/widgets/promotion_card_widget.dart';
import 'package:heroes_app/src/presentation/widgets/searchable_category_selector.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class AllPromotionsView extends StatefulWidget {
  final String? initialCategoryId;
  final PromotionFilter? filter;
  const AllPromotionsView({super.key, this.initialCategoryId, this.filter});

  @override
  State<AllPromotionsView> createState() => _AllPromotionsViewState();
}

class _AllPromotionsViewState extends State<AllPromotionsView> {
  @override
  void initState() {
    super.initState();

    // Load categories for filtering
    if (context.read<AllPromotionsCubit>().state.categories.isEmpty) {
      context.read<AllPromotionsCubit>().getBusinessCategories();
    }

    // Set the initial filter if provided
    if (widget.filter != null) {
      context.read<AllPromotionsCubit>().setInitialFilter(widget.filter);
    } else if (widget.initialCategoryId != null) {
      context.read<AllPromotionsCubit>().setSelectedCategoryId(
        widget.initialCategoryId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var locator = GetIt.instance;
    var theme = Theme.of(context);
    var texts = locator<AppConstants>().dashBoardTexts["allPromotionsView"]!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<AllPromotionsCubit>().handleOnPop(context);
        }
      },

      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: BlocBuilder<AllPromotionsCubit, AllPromotionsState>(
          builder: (context, state) {
            switch (state.status) {
              case PromotionViewCubitStatus.initial:
                return loadingView(theme, texts);
              case PromotionViewCubitStatus.loading:
                getAllPromotions(context);
                return loadingView(theme, texts);
              case PromotionViewCubitStatus.success:
                return succesView(theme, texts, state.promotions, context);
              case PromotionViewCubitStatus.error:
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
        if (context.read<AllPromotionsCubit>().state.categories.isNotEmpty)
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
                  onPressed: () => getAllPromotions(context),
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
    List<Promotion> promotions,
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
          sliver: promotionsList(promotions, theme, texts),
        ),
      ],
    );
  }

  //Widgets
  Widget promotionsList(List<Promotion> promotions, theme, texts) {
    return promotions.isNotEmpty
        ? SliverList.builder(
          itemCount: promotions.length,
          itemBuilder: (context, index) {
            final promotion = promotions[index];
            _trackPromotionImpression(promotion.documentId ?? '', promotion.businessId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PromotionCard(
                promotion: promotion,
                callback: () {
                  AutoRouter.of(context).push(
                    PromotionDetailsView(
                      promotionId: promotion.documentId ?? '',
                      promotion: promotion,
                    ),
                  );
                },
              ),
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
    return BlocBuilder<AllPromotionsCubit, AllPromotionsState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SearchableCategorySelector(
            categories: state.categories,
            selectedCategoryId: state.selectedCategoryId,
            onCategorySelected: (categoryId) {
              context.read<AllPromotionsCubit>().setSelectedCategoryId(categoryId ?? '');
            },
            allCategoriesText: texts["all-categories"],
          ),
        );
      },
    );
  }

  //Methods
  void getAllPromotions(BuildContext context) {
    context.read<AllPromotionsCubit>().getPromotions();
  }

  // V2: Track promotion impression in search results
  void _trackPromotionImpression(String promotionId, String businessId) {
    final analyticsService = GetIt.instance.get<AnalyticsService>();
    analyticsService.trackDashboardImpression(
      entityType: 'promotion',
      entityId: promotionId,
      businessId: businessId,
      screen: 'promotions_feed',
    );
  }
}
