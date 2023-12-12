import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_home_view/business_home_view_cubit.dart';
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/delegates/search_business_delegate.dart';
import 'package:heroes_app/src/presentation/widgets/horizontal_card_widget.dart';
import 'package:heroes_app/src/presentation/widgets/map_preview_widget.dart';
import 'package:heroes_app/src/presentation/widgets/vertical_card_widget.dart';

@RoutePage()
class SearchView extends StatelessWidget {
  SearchView({Key? key}) : super(key: key);
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
            return loadingView(texts);
          case BusinessViewCubitStatus.loading:
            return loadingView(texts);
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
        SliverAppBar.large(
          title: Text(texts["title"]),
          pinned: true,
        ),
        searchButton(theme, texts, context),
        singleTitle(theme, texts),
        mapPreview(theme, context),
        doubleTitle(theme, texts["featuredBusiness"], texts["seeAll"], () {
          AutoRouter.of(context).push(const AllBusinessView());
        }),
        horizontalList(state.featuredBusinesses),
        doubleTitle(theme, texts["business"], texts["seeAll"], () {
          AutoRouter.of(context).push(const AllBusinessView());
        }),
        verticalList(state.normalBusinesses),
        const SliverToBoxAdapter(child: SizedBox(height: 16))
      ],
    );
  }

  CustomScrollView loadingView(texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          pinned: true,
          title: Text(texts["title"]),
        ),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(),
          ),
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

  SliverToBoxAdapter singleTitle(ThemeData theme, texts) {
    return SliverToBoxAdapter(
        child: Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ListTile(
        title: Text(
          texts["nearPromotions"],
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: theme.textTheme.labelLarge!.fontSize,
            fontWeight: theme.textTheme.labelLarge!.fontWeight,
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
              fontWeight: theme.textTheme.labelLarge!.fontWeight,
            ),
          ),
          trailing: Text(buttonText),
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
