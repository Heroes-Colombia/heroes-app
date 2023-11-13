import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/presentation/cubits/favourite%20businesses/favourite_businesses_cubit.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/presentation/widgets/horizontal_card_widget.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class FavoritesView extends StatelessWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var locator = GetIt.instance;
    final texts = locator<AppConstants>().dashBoardTexts["favouriteView"];
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<FavouriteBusinessesCubit, FavouriteBusinessesState>(
        builder: (context, state) {
          switch (state.status) {
            case BusinessViewCubitStatus.loading:
              getFavouriteBusinesses(context);
              return loadingView(texts);
            case BusinessViewCubitStatus.success:
              return succesView(texts, theme, state.businesses);
            default:
              return errorView(texts, theme, context);
          }
        },
      ),
    );
  }

  //View state methods
  Widget loadingView(texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(texts["title"]!),
        ),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget errorView(texts, theme, context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(texts["error-title"])),
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
                onPressed: () => getFavouriteBusinesses(context),
                label: Text(texts["error-button"]),
              )
            ],
          )),
        )
      ],
    );
  }

  Widget succesView(texts, theme, List<ListableBusiness> businesses) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(texts["title"]!)),
        SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          sliver: businessGrid(businesses, theme),
        )
      ],
    );
  }

  //Widgets
  //TODO: Fix bug on hero animation in business details
  SliverGrid businessGrid(List<ListableBusiness> businesses, theme) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 174,
      ),
      itemCount: businesses.length,
      itemBuilder: (context, index) {
        return HorizontalCard(
          isOnGrid: true,
          image: businesses[index].featuredImage,
          title: businesses[index].name,
          id: businesses[index].id,
          callback: () {
            AutoRouter.of(context).push(
              BusinessDetailsView(
                businessId: businesses[index].id,
              ),
            );
          },
          heroName: businesses[index].id,
        );
      },
    );
  }

  //Methods
  void getFavouriteBusinesses(BuildContext context) {
    context.read<FavouriteBusinessesCubit>().getFavouriteBusinesses();
  }
}
