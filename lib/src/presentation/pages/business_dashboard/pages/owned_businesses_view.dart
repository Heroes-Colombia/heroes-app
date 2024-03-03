import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/presentation/cubits/manage_business/owned_businesses/owned_businesses_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/horizontal_card_widget.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class OwnedBusinessesView extends StatelessWidget {
  OwnedBusinessesView({super.key});
  final GetIt locator = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => await getOwnedBusinesses(context),
        child: BlocBuilder<OwnedBusinessesCubit, OwnedBusinessesState>(
            builder: (context, state) {
          switch (state.status) {
            case BusinessViewCubitStatus.initial:
              return loadingView(context);
            case BusinessViewCubitStatus.loading:
              context.read<OwnedBusinessesCubit>().getOwnedBusinesses();
              return loadingView(context);
            case BusinessViewCubitStatus.success:
              return successView(context, state.businesses);
            case BusinessViewCubitStatus.error:
              return errorView(context);
            default:
              return errorView(context);
          }
        }),
      ),
    );
  }

  //View state methods
  Widget loadingView(BuildContext context) {
    var theme = Theme.of(context);
    var texts = locator
        .get<AppConstants>()
        .businessDashboardTexts["ownedBusinessesView"]!;
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
            title: Text(
          texts["loading-title"]!,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
            fontSize: theme.textTheme.headlineSmall!.fontSize,
          ),
        )),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        )
      ],
    );
  }

  Widget successView(BuildContext context, List<ListableBusiness> businesses) {
    var texts = locator
        .get<AppConstants>()
        .businessDashboardTexts["ownedBusinessesView"]!;

    var theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
            "",
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              fontSize: theme.textTheme.headlineSmall!.fontSize,
            ),
          ),
        ),
        logo(theme, texts),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              texts["title"]!,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
                fontSize: theme.textTheme.labelLarge!.fontSize,
              ),
            ),
          ),
        ),
        businesses.isNotEmpty
            ? businessesGrid(businesses)
            : SliverFillRemaining(
                child: Center(
                  child: Text(
                    texts["empty-content"]!,
                    style: TextStyle(
                      color: theme.colorScheme.onBackground,
                      fontSize: theme.textTheme.labelLarge!.fontSize,
                      fontWeight: theme.textTheme.labelLarge!.fontWeight,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget errorView(context) {
    var texts = locator
        .get<AppConstants>()
        .businessDashboardTexts["ownedBusinessesView"]!;

    var theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
            title: Text(
          texts["error-title"]!,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
            fontSize: theme.textTheme.headlineSmall!.fontSize,
          ),
        )),
        SliverFillRemaining(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                texts["error-content"]!,
                style: theme.textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Ionicons.refresh),
                onPressed: () => getOwnedBusinesses(context),
                label: Text(texts["error-button"]!),
              )
            ],
          )),
        )
      ],
    );
  }

  //Widget methods
  SliverPadding businessesGrid(List<ListableBusiness> businesses) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 194,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return HorizontalCard(
              image: businesses[index].featuredImage,
              title: businesses[index].name,
              id: businesses[index].id,
              isOnGrid: true,
              category: businesses[index].category,
              callback: () => AutoRouter.of(context).push(
                  OwnedBusinessDetailsView(businessId: businesses[index].id)),
            );
          },
          childCount: businesses.length,
        ),
      ),
    );
  }

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

  //Methods
  Future<void> getOwnedBusinesses(BuildContext context) async {
    await context.read<OwnedBusinessesCubit>().getOwnedBusinesses();
  }
}
