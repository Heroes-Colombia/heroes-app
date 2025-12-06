import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/presentation/cubits/favourite_businesses/favourite_businesses_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_home_view/business_home_view_cubit.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/presentation/widgets/horizontal_card_widget.dart';
import 'package:heroes_app/src/presentation/widgets/promotion_card_widget.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locator = GetIt.instance;
    final texts = locator<AppConstants>().dashBoardTexts["favouriteView"];
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<FavouriteBusinessesCubit, FavouriteBusinessesState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(
                  texts?["title"] ?? 'Favoritos',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                    fontSize: theme.textTheme.headlineSmall!.fontSize,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: theme.colorScheme.surface,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: theme.colorScheme.primary,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      tabs: const [
                        Tab(text: 'Negocios'),
                        Tab(text: 'Promociones'),
                      ],
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Businesses Tab
                    _buildBusinessesTab(context, state, texts, theme),
                    // Promotions Tab
                    _buildPromotionsTab(context, state, texts, theme),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBusinessesTab(
    BuildContext context,
    FavouriteBusinessesState state,
    Map<String, String>? texts,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: () => getFavouriteBusinesses(context),
      child: Builder(
        builder: (context) {
          switch (state.status) {
            case BusinessViewCubitStatus.loading:
              getFavouriteBusinesses(context);
              return const Center(child: CircularProgressIndicator());
            case BusinessViewCubitStatus.success:
              return _buildBusinessesList(state.businesses, theme, texts);
            case BusinessViewCubitStatus.error:
              return _buildErrorView(texts, theme, context, isBusinesses: true);
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPromotionsTab(
    BuildContext context,
    FavouriteBusinessesState state,
    Map<String, String>? texts,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: () => getFavouritePromotions(context),
      child: Builder(
        builder: (context) {
          switch (state.promotionsStatus) {
            case BusinessViewCubitStatus.loading:
              getFavouritePromotions(context);
              return const Center(child: CircularProgressIndicator());
            case BusinessViewCubitStatus.success:
              return _buildPromotionsList(state.promotions, theme, texts);
            case BusinessViewCubitStatus.error:
              return _buildErrorView(
                texts,
                theme,
                context,
                isBusinesses: false,
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildBusinessesList(
    List<ListableBusiness> businesses,
    ThemeData theme,
    Map<String, String>? texts,
  ) {
    if (businesses.isEmpty) {
      return BlocBuilder<BusinessHomeViewCubit, BusinessHomeViewState>(
        builder: (context, homeState) {
          final recommendations = homeState.featuredBusinesses.take(3).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Ionicons.business_outline,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No tienes negocios favoritos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Explora negocios y guarda tus favoritos',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (recommendations.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Negocios Destacados',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...recommendations.map(
                    (business) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HorizontalCard(
                        isOnGrid: false,
                        image: business.featuredImage,
                        title: business.name,
                        id: business.id,
                        category: business.category,
                        callback: () {
                          AutoRouter.of(
                            context,
                          ).push(BusinessDetailsView(businessId: business.id));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Ionicons.search),
                    onPressed: () {
                      // Navigate to search/explore tab
                      AutoRouter.of(context).navigate(SearchView());
                    },
                    label: const Text('Explorar más negocios'),
                  ),
                ],
              ],
            ),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return HorizontalCard(
          isOnGrid: false,
          image: businesses[index].featuredImage,
          title: businesses[index].name,
          id: businesses[index].id,
          category: businesses[index].category,
          callback: () {
            AutoRouter.of(
              context,
            ).push(BusinessDetailsView(businessId: businesses[index].id));
          },
        );
      },
      itemCount: businesses.length,
    );
  }

  Widget _buildPromotionsList(
    List<dynamic> promotions,
    ThemeData theme,
    Map<String, String>? texts,
  ) {
    if (promotions.isEmpty) {
      return BlocBuilder<BusinessHomeViewCubit, BusinessHomeViewState>(
        builder: (context, homeState) {
          final recommendations = homeState.featuredPromotions.take(3).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Ionicons.pricetag_outline,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No tienes promociones favoritas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Descubre promociones y guarda tus favoritas',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (recommendations.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Promociones Destacadas',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        final promotion = recommendations[index] as Promotion;
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Ionicons.search),
                    onPressed: () {
                      // Navigate to search/explore tab
                      AutoRouter.of(context).navigate(AllPromotionsView());
                    },
                    label: const Text('Explorar más promociones'),
                  ),
                ],
              ],
            ),
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final promotion = promotions[index] as Promotion;
        return _buildPromotionCard(promotion, theme);
      },
      itemCount: promotions.length,
    );
  }

  Widget _buildPromotionCard(Promotion promotion, ThemeData theme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          AutoRouter.of(context).push(
            PromotionDetailsView(
              promotion: promotion,
              promotionId: promotion.documentId,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promotion Image
            SizedBox(
              height: 180,
              width: double.infinity,
              child:
                  promotion.featuredImage.isNotEmpty
                      ? Image.network(
                        promotion.featuredImage,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          Ionicons.image_outline,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
            ),
            // Promotion Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discount badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${promotion.percentage}% OFF',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    promotion.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    promotion.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(
    Map<String, String>? texts,
    ThemeData theme,
    BuildContext context, {
    required bool isBusinesses,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.alert_circle_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              texts?["error-content"] ?? 'Error al cargar favoritos',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Ionicons.refresh),
              onPressed: () {
                if (isBusinesses) {
                  getFavouriteBusinesses(context);
                } else {
                  getFavouritePromotions(context);
                }
              },
              label: Text(texts?["error-button"] ?? 'Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getFavouriteBusinesses(BuildContext context) async {
    await context.read<FavouriteBusinessesCubit>().getFavouriteBusinesses();
  }

  Future<void> getFavouritePromotions(BuildContext context) async {
    await context.read<FavouriteBusinessesCubit>().getFavouritePromotions();
  }
}
