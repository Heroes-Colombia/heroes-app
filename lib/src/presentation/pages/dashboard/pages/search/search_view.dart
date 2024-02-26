import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_home_view/business_home_view_cubit.dart';
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/delegates/search_business_delegate.dart';
import 'package:heroes_app/src/presentation/widgets/horizontal_card_widget.dart';
import 'package:heroes_app/src/presentation/widgets/map_preview_widget.dart';
import 'package:heroes_app/src/presentation/widgets/vertical_card_widget.dart';

@RoutePage()
class SearchView extends StatelessWidget {
  SearchView({super.key});
  final locator = GetIt.instance;

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
      }),
    );
  }

  //View state methods
  CustomScrollView successView(context, texts, BusinessHomeViewState state) {
    var theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          stretch: true,
          pinned: true,
          actions: [
            IconButton(
              onPressed: () => showSearch(
                  context: context, delegate: SearchBusinessDelegate()),
              icon: SvgPicture.asset(
                "assets/icon/search.svg",
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            )
          ],
        ),
        logo(theme, texts),
        singleTitle(theme, texts["categories"]),
        categoriesList(state.businessCategories),
        singleTitle(theme, texts["nearPromotions"]),
        mapPreview(theme, context),
        doubleTitle(theme, texts["featuredBusiness"], texts["seeAll"], () {
          AutoRouter.of(context).push(AllBusinessView(initialCategoryId: null));
        }),
        horizontalList(state.featuredBusinesses),
        doubleTitle(theme, texts["business"], texts["seeAll"], () {
          AutoRouter.of(context).push(AllBusinessView(initialCategoryId: null));
        }),
        verticalList(state.normalBusinesses),
        const SliverToBoxAdapter(child: SizedBox(height: 16))
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
            )
          ],
        ),
        logo(theme, texts),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        )
      ],
    );
  }

  CustomScrollView errorView(texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          pinned: true,
          title: Text(texts["title"]),
        ),
        const SliverFillRemaining(
          child: Center(
            child: Text("Error"),
          ),
        )
      ],
    );
  }

  //Widget methods
  SliverToBoxAdapter logo(ThemeData theme, texts) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Hero(
          tag: "loading-logo",
          child: SvgPicture.asset("assets/images/heroes_white_logo.svg",
              width: double.infinity,
              height: 40,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              )),
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
            showSearch(
              context: context,
              delegate: SearchBusinessDelegate(),
            );
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
                Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
    ));
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
        child: InkWell(
          onTap: () {
            AutoRouter.of(context).push(const MapView());
          },
          child: const MapPreviewWidget(
            borderRadius: 20,
            latitude: null,
            longitude: null,
          ),
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
              onTap: () => AutoRouter.of(context).push(
                AllBusinessView(
                  initialCategoryId: businessCategories[index].id,
                ),
              ),
              child: Container(
                height: 48,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.5),
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
        height: 174,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView.separated(
          padding: const EdgeInsets.all(0.0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return HorizontalCard(
              image: featuredBusinesses[index].featuredImage,
              title: featuredBusinesses[index].name,
              id: featuredBusinesses[index].id,
              callback: () {
                AutoRouter.of(context).push(BusinessDetailsView(
                    businessId: featuredBusinesses[index].id));
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

  SliverList verticalList(List<ListableBusiness> businesses) {
    return SliverList.separated(
      itemBuilder: (context, index) {
        return VerticalCard(
          image: businesses[index].featuredImage,
          title: businesses[index].name,
          id: businesses[index].id,
          callback: () {
            AutoRouter.of(context).push(
              BusinessDetailsView(businessId: businesses[index].id),
            );
          },
        );
      },
      itemCount: businesses.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 16);
      },
    );
  }
}
