import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/business_filter.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_filter.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_home_view/business_home_view_cubit.dart';
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/delegates/search_business_delegate.dart';
import 'package:heroes_app/src/presentation/widgets/horizontal_card_widget.dart';
import 'package:heroes_app/src/presentation/widgets/map_interactive_widget.dart';
import 'package:heroes_app/src/presentation/widgets/promotion_card_widget.dart';
import 'package:heroes_app/src/presentation/widgets/vertical_card_widget.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:heroes_app/src/domain/services/onboarding_service.dart';

@RoutePage()
class SearchView extends StatefulWidget {
  final GlobalKey? promotionsKey;

  const SearchView({super.key, this.promotionsKey});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final locator = GetIt.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Infinite scroll listener
  void _onScroll() {
    if (_isBottom) {
      context.read<BusinessHomeViewCubit>().loadMoreNormalBusinesses();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final isBottom = currentScroll >= (maxScroll * 0.9);
    return isBottom; // Trigger at 90% scroll
  }

  @override
  Widget build(BuildContext context) {
    var texts = locator<AppConstants>().dashBoardTexts["searchView"];
    return Scaffold(
      body: BlocBuilder<BusinessHomeViewCubit, BusinessHomeViewState>(
        builder: (context, state) {
          switch (state.businessHomeViewState) {
            case BusinessViewCubitStatus.initial:
              context.read<BusinessHomeViewCubit>().getRequiredData();
              return loadingView(texts, Theme.of(context));
            case BusinessViewCubitStatus.loading:
              return loadingView(texts, Theme.of(context));
            case BusinessViewCubitStatus.success:
              return successView(context, texts, state);
            default:
              return errorView(texts);
          }
        },
      ),
    );
  }

  //View state methods
  CustomScrollView successView(context, texts, BusinessHomeViewState state) {
    var theme = Theme.of(context);
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          stretch: true,
          pinned: true,
          actions: [
            IconButton(
              onPressed:
                  () => showSearch(
                    context: context,
                    delegate: SearchBusinessDelegate(),
                  ),
              icon: SvgPicture.asset(
                "assets/icon/search.svg",
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        logo(theme, texts),
        // Featured promotions carousel (only show if there are promotions)
        if (state.featuredPromotions.isNotEmpty) ...[
          doubleTitle(theme, "Ofertas Destacadas", texts["seeAll"], () {
            AutoRouter.of(
              context,
            ).push(AllPromotionsView(filter: const PromotionFilter.featured()));
          }),
          featuredPromotionsCarouselWithShowcase(
            state.featuredPromotions,
            context,
          ),
        ],
        singleTitle(theme, texts["categories"]),
        categoriesList(state.businessCategories),
        singleTitle(theme, texts["nearPromotions"]),
        mapPreview(theme, context),
        doubleTitle(theme, texts["featuredBusiness"], texts["seeAll"], () {
          AutoRouter.of(
            context,
          ).push(AllBusinessView(filter: const BusinessFilter.featured()));
        }),
        horizontalList(state.featuredBusinesses),
        // Online businesses section (only show if there are online businesses)
        if (state.onlineBusinesses.isNotEmpty) ...[
          doubleTitle(theme, "Negocios en Línea", texts["seeAll"], () {
            AutoRouter.of(
              context,
            ).push(AllBusinessView(filter: const BusinessFilter.online()));
          }),
          horizontalList(state.onlineBusinesses),
        ],
        if (state.normalBusinesses.isNotEmpty) ...[
          doubleTitle(theme, "Negocios Físicos", texts["seeAll"], () {
            AutoRouter.of(
              context,
            ).push(AllBusinessView(filter: const BusinessFilter.physical()));
          }),
          verticalList(state.normalBusinesses, state.businessPromotions),
          // Loading indicator for pagination
          if (state.isLoadingMore)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ],
    );
  }

  CustomScrollView loadingView(texts, theme) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          stretch: true,
          pinned: true,
          actions: [
            IconButton(
              onPressed: () => {},
              icon: SvgPicture.asset(
                "assets/icon/search.svg",
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        logo(theme, texts),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  CustomScrollView errorView(texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(pinned: true, title: Text(texts["title"])),
        const SliverFillRemaining(child: Center(child: Text("Error"))),
      ],
    );
  }

  //Widget methods
  SliverToBoxAdapter logo(ThemeData theme, texts) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Hero(
          tag: "loading-logo",
          child: SvgPicture.asset(
            "assets/images/heroes_white_logo.svg",
            width: double.infinity,
            height: 40,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter searchButton(
    ThemeData theme,
    texts,
    BuildContext context,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          onTap: () {
            //open search delegate
            showSearch(context: context, delegate: SearchBusinessDelegate());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  texts["search-title"],
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: theme.textTheme.labelLarge!.fontSize,
                    fontWeight: theme.textTheme.labelLarge!.fontWeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter singleTitle(ThemeData theme, text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: ListTile(
          title: Text(
            text,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: theme.textTheme.labelLarge!.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter mapPreview(ThemeData theme, BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        height: 200,
        child: const MapInteractiveWidget(
          borderRadius: 20,
          latitude: null,
          longitude: null,
        ),
      ),
    );
  }

  SliverToBoxAdapter doubleTitle(
    ThemeData theme,
    String title,
    String buttonText,
    Function callback,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          onTap: () => callback(),
          title: Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: theme.textTheme.labelLarge!.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Text(
            buttonText,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: theme.textTheme.labelMedium!.fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget categoriesList(List<BusinessCategory> businessCategories) {
    return SliverToBoxAdapter(
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView.separated(
          padding: const EdgeInsets.all(0.0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return InkWell(
              onTap:
                  () => AutoRouter.of(context).push(
                    AllBusinessView(
                      initialCategoryId: businessCategories[index].id,
                    ),
                  ),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(businessCategories[index].name),
                    const SizedBox(width: 8),
                    SvgPicture.network(
                      businessCategories[index].imageUrl,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(width: 16);
          },
          itemCount: businessCategories.length,
        ),
      ),
    );
  }

  Widget horizontalList(List<ListableBusiness> featuredBusinesses) {
    return SliverToBoxAdapter(
      child: Container(
        height: 250,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView.separated(
          padding: const EdgeInsets.all(0.0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return HorizontalCard(
              image: featuredBusinesses[index].featuredImage,
              title: featuredBusinesses[index].name,
              id: featuredBusinesses[index].id,
              isOnGrid: true,
              category: featuredBusinesses[index].category,
              businessType: featuredBusinesses[index].type,
              callback: () {
                AutoRouter.of(context).push(
                  BusinessDetailsView(businessId: featuredBusinesses[index].id),
                );
              },
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(width: 16);
          },
          itemCount: featuredBusinesses.length,
        ),
      ),
    );
  }

  SliverList verticalList(
    List<ListableBusiness> businesses,
    Map<String, dynamic> businessPromotions,
  ) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return VerticalCard(
          image: businesses[index].featuredImage,
          title: businesses[index].name,
          id: businesses[index].id,
          category: businesses[index].category,
          businessType: businesses[index].type,
          urgentPromotion: businessPromotions[businesses[index].id],
          formattedDistance: businesses[index].formattedDistance,
          isFeatured: businesses[index].featured,
          physicalLocationsCount: businesses[index].physicalLocationsCount,
          callback: () {
            AutoRouter.of(
              context,
            ).push(BusinessDetailsView(businessId: businesses[index].id));
          },
        );
      },
      itemCount: businesses.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 16);
      },
    );
  }

  Widget featuredPromotionsCarousel(
    List<dynamic> promotions,
    BuildContext context,
  ) {
    final cubit = context.read<BusinessHomeViewCubit>();
    final state = context.watch<BusinessHomeViewCubit>().state;

    return SliverToBoxAdapter(
      child: Container(
        height: 280,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView.builder(
          padding: const EdgeInsets.all(0.0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            // Load more when reaching 3 items before the end
            if (index == promotions.length - 3 &&
                state.hasMorePromotions &&
                !state.isLoadingMorePromotions) {
              cubit.loadMorePromotions();
            }

            // Show loading indicator at the end
            if (index == promotions.length) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final promotion = promotions[index] as Promotion;
            _trackPromotionImpression(
              promotion.documentId ?? '',
              promotion.businessId,
            );
            return PromotionCard(
              promotion: promotion,
              callback: () {
                AutoRouter.of(context).push(
                  PromotionDetailsView(
                    promotionId: promotion.documentId ?? '',
                    promotion: promotion,
                  ),
                );
              },
            );
          },
          // Add 1 to itemCount if loading more (for loading indicator)
          itemCount:
              promotions.length +
              (state.isLoadingMorePromotions && state.hasMorePromotions
                  ? 1
                  : 0),
        ),
      ),
    );
  }

  // V2: Track promotion impression in featured carousel
  void _trackPromotionImpression(String promotionId, String businessId) {
    final analyticsService = GetIt.instance.get<AnalyticsService>();
    analyticsService.trackDashboardImpression(
      entityType: 'promotion',
      entityId: promotionId,
      businessId: businessId,
      screen: 'home_feed',
    );
  }

  // Showcase-wrapped widgets for onboarding
  Widget featuredPromotionsCarouselWithShowcase(
    List<dynamic> promotions,
    BuildContext context,
  ) {
    return SliverToBoxAdapter(
      child: Showcase(
        key: widget.promotionsKey ?? GlobalKey(),
        description:
            'Aquí encontrarás las mejores ofertas destacadas de negocios cercanos a ti.',
        child: Container(
          height: 280,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: _buildPromotionsCarousel(promotions, context),
        ),
      ),
    );
  }

  Widget _buildPromotionsCarousel(
    List<dynamic> promotions,
    BuildContext context,
  ) {
    final cubit = context.read<BusinessHomeViewCubit>();
    final state = context.watch<BusinessHomeViewCubit>().state;

    return ListView.builder(
      padding: const EdgeInsets.all(0.0),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        // Load more when reaching 3 items before the end
        if (index == promotions.length - 3 &&
            state.hasMorePromotions &&
            !state.isLoadingMorePromotions) {
          cubit.loadMorePromotions();
        }

        // Show loading indicator at the end
        if (index == promotions.length) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final promotion = promotions[index] as Promotion;
        _trackPromotionImpression(
          promotion.documentId ?? '',
          promotion.businessId,
        );
        return PromotionCard(
          promotion: promotion,
          callback: () {
            AutoRouter.of(context).push(
              PromotionDetailsView(
                promotionId: promotion.documentId ?? '',
                promotion: promotion,
              ),
            );
          },
        );
      },
      itemCount:
          promotions.length +
          (state.isLoadingMorePromotions && state.hasMorePromotions ? 1 : 0),
    );
  }
}
