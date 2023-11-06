import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/presentation/cubits/business%20details/business_details_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/vertical_card_widget.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class BusinessDetailsView extends StatefulWidget {
  final String businessId;
  const BusinessDetailsView({super.key, required this.businessId});

  @override
  State<BusinessDetailsView> createState() => _BusinessDetailsViewState();
}

class _BusinessDetailsViewState extends State<BusinessDetailsView> {
  @override
  void initState() {
    super.initState();
    context.read<BusinessDetailsCubit>().getInitial();
  }

  @override
  Widget build(BuildContext context) {
    final locator = GetIt.instance;
    final texts = locator<AppConstants>().dashBoardTexts["businessDetailsView"];
    final theme = Theme.of(context);

    return Scaffold(
        body: BlocBuilder<BusinessDetailsCubit, BusinessDetailsState>(
      builder: (context, state) {
        switch (state.status) {
          case BusinessViewCubitStatus.initial:
            return loadingView(theme, texts);
          case BusinessViewCubitStatus.loading:
            getBusinessDetails();
            return loadingView(theme, texts);
          case BusinessViewCubitStatus.success:
            return succesView(theme, texts, state.business!, state.promotions);
          case BusinessViewCubitStatus.error:
            return errorView(theme, texts);
          default:
            return const Center(child: Text('Error'));
        }
      },
    ));
  }

  //View state methods

  CustomScrollView loadingView(ThemeData theme, texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(texts["loading-title"])),
        SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          ),
        )
      ],
    );
  }

  CustomScrollView errorView(ThemeData theme, texts) {
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
                onPressed: () => getBusinessDetails(),
                label: Text(texts["error-button"]),
              )
            ],
          )),
        )
      ],
    );
  }

  CustomScrollView succesView(
      ThemeData theme, texts, Business business, List<Promotion> promotions) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(business.name)),
        mainCard(business, theme, texts),
        separator(texts, theme),
        promotionsList(promotions, texts)
      ],
    );
  }

  //Widget methods

  SliverToBoxAdapter mainCard(Business business, ThemeData theme, texts) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (business.featuredImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  business.featuredImage,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/file-not-found.png',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {},
              child: Text(texts["navigation-title"]),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter separator(texts, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts["promotions-title"],
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget promotionsList(List<Promotion> promotions, texts) {
    return promotions.isNotEmpty
        ? SliverList.builder(
            itemBuilder: (context, index) {
              return VerticalCard(
                  image: promotions[index].featuredImage,
                  title: promotions[index].title,
                  id: promotions[index].businessId,
                  description: promotions[index].description,
                  callback: () {
                    AutoRouter.of(context).push(
                        PromotionDetailsView(promotion: promotions[index]));
                  });
            },
            itemCount: promotions.length,
          )
        : SliverToBoxAdapter(
            child: VerticalCard(
              image: "",
              title: texts["empty-promotions-title"]!,
              description: texts["empty-promotions"]!,
              id: "",
              callback: () {},
            ),
          );
  }

  //Methods

  void getBusinessDetails() {
    context.read<BusinessDetailsCubit>().getBusinessDetails(widget.businessId);
  }
}
