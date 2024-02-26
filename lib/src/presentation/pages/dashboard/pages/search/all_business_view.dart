import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/presentation/cubits/business/all_business/all_business_cubit.dart';
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/delegates/categories_header_delegate.dart';
import 'package:heroes_app/src/presentation/widgets/horizontal_card_widget.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class AllBusinessView extends StatefulWidget {
  final String? initialCategoryId;
  const AllBusinessView({super.key, this.initialCategoryId});

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

    context
        .read<AllBusinessCubit>()
        .setSelectedCategoryId(widget.initialCategoryId);
  }

  @override
  Widget build(BuildContext context) {
    var locator = GetIt.instance;
    var theme = Theme.of(context);
    var texts = locator<AppConstants>().dashBoardTexts["allBusinessView"]!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) =>
          context.read<AllBusinessCubit>().handleOnPop(context),
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
                    child: categoriesDropDown(theme, texts))),
          ),
        const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()))
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
        )),
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
                  child: categoriesDropDown(theme, texts))),
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
          child: FormBuilderDropdown(
            name: "categories",
            initialValue: state.selectedCategoryId,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 16),
            ),
            items: [
              DropdownMenuItem(
                value: "",
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icon/allCategories.svg",
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      texts["all-categories"],
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: theme.textTheme.labelLarge!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...state.categories.map(
                (e) => DropdownMenuItem(
                  value: e.id,
                  child: Row(
                    children: [
                      SvgPicture.network(
                        e.imageUrl,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        e.name,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: theme.textTheme.labelLarge!.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
            onChanged: (value) => context
                .read<AllBusinessCubit>()
                .setSelectedCategoryId(value as String),
          ),
        );
      },
    );
  }

  //Methods
  void getAllBusinesses(BuildContext context) {
    context.read<AllBusinessCubit>().getBusinesses();
  }
}
