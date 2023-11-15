import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/presentation/cubits/business/all_business/all_business_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/horizontal_card_widget.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class AllBusinessView extends StatelessWidget {
  const AllBusinessView({super.key});

  @override
  Widget build(BuildContext context) {
    var locator = GetIt.instance;
    var theme = Theme.of(context);
    var texts = locator<AppConstants>().dashBoardTexts["allBusinessView"]!;

    return Scaffold(
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
    );
  }

  //View state methods
  CustomScrollView loadingView(ThemeData theme, texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(texts["loading-title"])),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        )
      ],
    );
  }

  CustomScrollView errorView(ThemeData theme, texts, BuildContext context) {
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
                onPressed: () => getAllBusinesses(context),
                label: Text(texts["error-button"]),
              )
            ],
          )),
        )
      ],
    );
  }

  CustomScrollView succesView(ThemeData theme, texts,
      List<ListableBusiness> businesses, BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          leading: IconButton(
            icon: const Icon(Ionicons.close),
            onPressed: () => AutoRouter.of(context).pop(),
          ),
          title: Text(texts["title"]),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          sliver: businessGrid(businesses, theme),
        )
      ],
    );
  }

  //Widgets
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
        );
      },
    );
  }

  //Methods
  void getAllBusinesses(BuildContext context) {
    context.read<AllBusinessCubit>().getBusinesses();
  }
}
