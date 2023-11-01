import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/presentation/cubits/business%20home%20view/business_home_view_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/horizontal_card_widget.dart';
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

  CustomScrollView successView(context, texts, BusinessHomeViewState state) {
    var theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(texts["title"]),
          pinned: true,
        ),
        searchButton(theme, texts),
        singleTitle(theme, texts),
        mapPreview(theme),
        doubleTitle(theme, texts["featuredBusiness"], texts["seeAll"], () {}),
        horizontalList(state.featuredBusinesses),
        doubleTitle(theme, texts["business"], texts["seeAll"], () {}),
        verticalList(state.featuredBusinesses),
        const SliverToBoxAdapter(child: SizedBox(height: 16))
      ],
    );
  }

  SliverToBoxAdapter searchButton(ThemeData theme, texts) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          onTap: () {},
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Text(
          texts["nearPromotions"],
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: theme.textTheme.labelLarge!.fontSize,
            fontWeight: theme.textTheme.labelLarge!.fontWeight,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter mapPreview(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        height: 200,
        child: const Center(),
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: theme.textTheme.labelLarge!.fontSize,
                  fontWeight: theme.textTheme.labelLarge!.fontWeight,
                ),
              ),
              InkWell(
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () => callback(),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: theme.textTheme.labelLarge!.fontSize,
                    fontWeight: theme.textTheme.labelLarge!.fontWeight,
                  ),
                ),
              )
            ]),
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
              image: featuredBusinesses[0].featuredImage,
              title: featuredBusinesses[0].name,
              id: featuredBusinesses[0].id,
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
          image: businesses[0].featuredImage,
          title: businesses[0].name,
          id: businesses[0].id,
        );
      },
      itemCount: businesses.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 16);
      },
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
}
