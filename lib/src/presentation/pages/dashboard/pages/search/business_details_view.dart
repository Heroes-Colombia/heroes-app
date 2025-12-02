import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/business_location.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/models/review_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_details/business_details_cubit.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:heroes_app/src/presentation/widgets/map_preview_widget.dart';
import 'package:heroes_app/src/presentation/widgets/vertical_card_widget.dart';
import 'package:heroes_app/src/presentation/widgets/business_location_item.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';

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
    context.read<BusinessDetailsCubit>().getAllBusinessReviews(
      widget.businessId,
    );
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
              return succesView(theme, texts, state);
            case BusinessViewCubitStatus.error:
              return errorView(theme, texts);
            default:
              return const Center(child: Text('Error'));
          }
        },
      ),
    );
  }

  //View state methods

  CustomScrollView loadingView(ThemeData theme, texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(
            texts["loading-title"],
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              fontSize: theme.textTheme.headlineSmall!.fontSize,
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  CustomScrollView errorView(ThemeData theme, texts) {
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
          ),
        ),
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  CustomScrollView succesView(
    ThemeData theme,
    texts,
    BusinessDetailsState state,
  ) {
    // Track business view analytics
    _trackBusinessView(state.business!);

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar.large(
          title: Text(
            state.business!.name,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              fontSize: theme.textTheme.headlineSmall!.fontSize,
            ),
          ),
        ),
        mainCard(
          state.business!,
          theme,
          texts,
          state.isFavourite,
          state.favouriteIsLoading,
          state.locations,
        ),
        SliverFillRemaining(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: texts["promotions-title"]),
                    Tab(
                      text:
                          state.business!.isOnline &&
                                  !state.business!.isPhysical
                              ? texts["online-access-title"] ?? "Acceso"
                              : texts["locations-title"] ?? "Ubicaciones",
                    ),
                    Tab(text: texts["information-title"]),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      promotionsList(state.promotions, texts, theme),
                      locationsTab(
                        state.business,
                        state.locations,
                        theme,
                        texts,
                      ),
                      informationTab(state.business, theme, texts),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //Widgets
  SliverToBoxAdapter mainCard(
    Business business,
    ThemeData theme,
    texts,
    bool isFavourite,
    bool favouriteIsLoading,
    List<BusinessLocation> locations,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (business.featuredImage.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    business.featuredImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
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
            const SizedBox(height: 1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (business.website != "" && business.website != null)
                  SizedBox(
                    width: 40,
                    child: IconButton.filledTonal(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          theme.colorScheme.background,
                        ),
                      ),
                      onPressed: () => openWebsite(business.website!),
                      icon: const Icon(Icons.language),
                    ),
                  ),
                const SizedBox(width: 5),
                if ((business.phoneNumber != "" && business.isOnline) ||
                    (business.isPhysical && business.phoneNumber != "")) ...[
                  SizedBox(
                    width: 40,
                    child: IconButton.filledTonal(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          theme.colorScheme.background,
                        ),
                      ),
                      onPressed: () => callBusiness(business.phoneNumber),
                      icon: const Icon(Ionicons.call_outline),
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 40,
                    child: IconButton.filledTonal(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          theme.colorScheme.background,
                        ),
                      ),
                      onPressed: () => openWhatsApp(business.phoneNumber),
                      icon: const Icon(Ionicons.logo_whatsapp),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                SizedBox(
                  width: 40,
                  child:
                      favouriteIsLoading
                          ? loadingHeart(theme)
                          : IconButton.filledTonal(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                theme.colorScheme.background,
                              ),
                            ),
                            onPressed: () {
                              setBusinessAsFavourite();
                            },
                            icon: Icon(
                              isFavourite && !favouriteIsLoading
                                  ? Ionicons.heart
                                  : Ionicons.heart_outline,
                              color:
                                  isFavourite && !favouriteIsLoading
                                      ? theme.colorScheme.primary
                                      : null,
                            ),
                          ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter sectionTitle(texts, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            texts["promotions-title"],
            style: theme.textTheme.labelLarge,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter sectionDoubleTitle(
    texts,
    ThemeData theme,
    List<UserReview> reviews,
  ) {
    return SliverToBoxAdapter(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(texts["comments-title"], style: theme.textTheme.labelLarge),
        onTap: () => seeAllComments(theme, texts),
        trailing: Text(texts["comments-button"]!),
      ),
    );
  }

  Widget promotionsList(List<Promotion> promotions, texts, theme) {
    return promotions.isNotEmpty
        ? GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.77,
          children:
              promotions
                  .where((element) => element.expiredAt.isAfter(DateTime.now()))
                  .map((promotion) => promotionCard(promotion, theme, texts))
                  .toList(),
        )
        : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder:
              (context, index) => VerticalCard(
                image: "",
                title: texts["empty-promotions-title"]!,
                description: texts["empty-promotions"]!,
                id: "",
                category: null,
                callback: () {},
              ),
          itemCount: 1,
        );
  }

  GestureDetector promotionCard(Promotion promotion, ThemeData theme, texts) {
    return GestureDetector(
      onTap:
          () => AutoRouter.of(
            context,
          ).push(PromotionDetailsView(promotion: promotion, promotionId: null)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                promotion.featuredImage,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 90,
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    height: 90,
                    "assets/images/file-not-found.png",
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    promotion.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.textTheme.labelLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${promotion.percentage}%",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: theme.textTheme.labelLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                promotion.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: theme.textTheme.labelLarge!.fontSize,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              promotion.expiredAt.difference(DateTime.now()).inDays < 2
                  ? texts["expires-today"]
                  : "${texts["days-remaining"]}${promotion.expiredAt.difference(DateTime.now()).inDays} ${texts["days-remaining-end"]}",
              style: TextStyle(
                fontSize: theme.textTheme.labelSmall!.fontSize,
                fontWeight: theme.textTheme.labelSmall!.fontWeight,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget informationTab(Business? business, ThemeData theme, texts) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description section
            if (business!.description != null &&
                business.description!.isNotEmpty) ...[
              _buildDescriptionSection(business.description!, theme, texts),
              const SizedBox(height: 24),
            ],
            // Email section
            if (business.email != null && business.email!.isNotEmpty) ...[
              Text(
                texts["email-title"] ?? "Correo electrónico",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: theme.textTheme.labelLarge!.fontSize,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => openEmail(business.email!),
                child: Text(
                  business.email!,
                  style: TextStyle(
                    fontSize: theme.textTheme.bodyMedium!.fontSize,
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget locationsTab(
    Business? business,
    List<BusinessLocation> locations,
    ThemeData theme,
    texts,
  ) {
    // If no locations subcollection, show primary business location (backward compatibility)
    if (locations.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                texts["address-title"]!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: theme.textTheme.labelLarge!.fontSize,
                ),
              ),
              const SizedBox(height: 4),
              Text(business!.address),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                height: 200,
                child: MapPreviewWidget(
                  borderRadius: 20,
                  latitude: business.location.latitude,
                  longitude: business.location.longitude,
                ),
              ),
            ],
          );
        },
      );
    }

    // Show all locations using BusinessLocationItem widget
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];

        return BusinessLocationItem(
          location: location,
          onNavigate: () {
            // Use shared navigation utility for physical locations
            if (location.isPhysical && location.location != null) {
              final locator = GetIt.instance;
              locator.get<AppMethods>().navigateToLocation(
                context: context,
                latitude: location.location!.latitude,
                longitude: location.location!.longitude,
                address: location.address ?? '',
                texts: texts,
              );
            } else if (location.isOnline && business!.website != "") {
              // Open website for online locations
              openWebsite(business.website!);
            }
          },
          onCall:
              location.phone != null && location.phone!.isNotEmpty
                  ? () => callBusiness(location.phone!)
                  : null,
          onWhatsApp:
              location.phone != null && location.phone!.isNotEmpty
                  ? () => openWhatsApp(location.phone!)
                  : null,
          website: business!.website,
        );
      },
    );
  }

  Widget _buildDescriptionSection(String description, ThemeData theme, texts) {
    // Calculate word count
    final words = description.split(RegExp(r'\s+'));
    final shouldTruncate = words.length > 20;

    return _DescriptionWidget(
      description: description,
      words: words,
      shouldTruncate: shouldTruncate,
      theme: theme,
      texts: texts,
    );
  }

  Container emptyCommentsCard(ThemeData theme, texts) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            texts["empty-comment-title"]!,
            style: theme.textTheme.labelLarge,
          ),
          TextButton(
            onPressed: () => seeRaitingMenu(),
            child: Text(texts["add-comment-button"]!),
          ),
        ],
      ),
    );
  }

  Widget commentCard(ThemeData theme, UserReview review) {
    var locator = GetIt.instance;
    var texts = locator<AppConstants>().dashBoardTexts["businessDetailsView"]!;

    return Container(
      padding: const EdgeInsets.all(16),
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            review.comment,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
            style: TextStyle(
              fontSize: theme.textTheme.labelLarge!.fontSize,
              fontWeight: theme.textTheme.labelLarge!.fontWeight,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            "${texts["raiting"]}: ${review.rate}",
            style: TextStyle(
              fontSize: theme.textTheme.labelLarge!.fontSize,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget addCommentCard(ThemeData theme, texts) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            texts["add-comment-title"]!,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
            style: TextStyle(
              fontSize: theme.textTheme.labelLarge!.fontSize,
              fontWeight: theme.textTheme.labelLarge!.fontWeight,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: () => seeRaitingMenu(),
            child: Text(texts["add-comment-button"]!),
          ),
        ],
      ),
    );
  }

  Widget loadingHeart(ThemeData theme) {
    return SizedBox(
      width: 40,
      child: Stack(
        children: [
          IconButton.filledTonal(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                theme.colorScheme.background,
              ),
            ),
            onPressed: null,
            icon: const Icon(Ionicons.heart_outline, color: null),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget allCommentsBottomModalBody() {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts = locator<AppConstants>().dashBoardTexts["businessDetailsView"]!;

    return BlocBuilder<BusinessDetailsCubit, BusinessDetailsState>(
      builder: (context, state) {
        return Container(
          color: theme.colorScheme.background,
          child:
              state.allUserReviews.isNotEmpty
                  ? ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemBuilder: (context, index) {
                      var theme = Theme.of(context);
                      return index == 0
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => seeRaitingMenu(),
                                child: Text(texts["add-comment-button"]!),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.allUserReviews[index].comment,
                                      style: theme.textTheme.labelLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${texts["raiting"]!}: ${state.allUserReviews[index].rate}",
                                          style: theme.textTheme.labelMedium!
                                              .copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.9),
                                              ),
                                        ),
                                        Text(
                                          DateFormat(
                                            "dd/MM/yyyy, hh:mm a",
                                            "es",
                                          ).format(
                                            state
                                                .allUserReviews[index]
                                                .createdAt,
                                          ),
                                          style: theme.textTheme.labelMedium!
                                              .copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.9),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                          : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.allUserReviews[index].comment,
                                  style: theme.textTheme.labelLarge,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${texts["raiting"]!}: ${state.allUserReviews[index].rate}",
                                      style: theme.textTheme.labelMedium!
                                          .copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.9),
                                          ),
                                    ),
                                    Text(
                                      DateFormat(
                                        "dd/MM/yyyy, hh:mm a",
                                        "es",
                                      ).format(
                                        state.allUserReviews[index].createdAt,
                                      ),
                                      style: theme.textTheme.labelMedium!
                                          .copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.9),
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 16);
                    },
                    itemCount: state.allUserReviews.length,
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            texts["empty-comment-title"]!,
                            style: theme.textTheme.labelLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => seeRaitingMenu(),
                            child: Text(texts["add-comment-button"]!),
                          ),
                        ],
                      );
                    },
                    itemCount: 1,
                  ),
        );
      },
    );
  }

  //Methods
  //This method is used to get the business details
  void getBusinessDetails() {
    checkIfBusinessIsMarkedAsFavourite();
    context.read<BusinessDetailsCubit>().getBusinessDetails(widget.businessId);
  }

  //This method is used to set a business as favourite
  void setBusinessAsFavourite() {
    final state = context.read<BusinessDetailsCubit>().state;
    if (state.business == null) return;

    final willBeFavorite = !state.isFavourite;

    if (willBeFavorite) {
      _trackFavoriteToggle(state.business!, true);
    }

    context.read<BusinessDetailsCubit>().setBusinessAsFavourite(
      widget.businessId,
    );
  }

  //This method is used to check if a business is marked as favourite
  void checkIfBusinessIsMarkedAsFavourite() {
    context.read<BusinessDetailsCubit>().businessIsMarkedAsFavorite(
      widget.businessId,
    );
  }

  //This method is used to see all the comments of a business
  void seeAllComments(ThemeData theme, texts) {
    context.read<BusinessDetailsCubit>().getAllBusinessReviews(
      widget.businessId,
    );

    //We create the body of the modal
    Widget body = allCommentsBottomModalBody();

    //We show the modal
    showBottomModal(
      body,
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
    );
  }

  //This method is used to see the raiting menu
  void seeRaitingMenu() {
    var locator = GetIt.instance;
    var texts = locator<AppConstants>().dashBoardTexts["businessDetailsView"]!;

    //We create the body of the modal
    var formKey = GlobalKey<FormBuilderState>();
    var theme = Theme.of(context);

    //We create the form
    Widget body = FormBuilder(
      key: formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(texts["add-review"]!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: "comment",
              validator:
                  (value) => locator
                      .get<AppMethods>()
                      .emptyStringValidatorWithMaxLength(
                        value,
                        texts["comment-validator"]!,
                        300,
                      ),
              maxLength: 300,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: texts["comment"]!,
                hintText: texts["comment-hint"]!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FormBuilderRatingBar(
              name: "raiting",
              wrapAlignment: WrapAlignment.center,
              allowHalfRating: true,
              glow: false,
              glowColor: Theme.of(context).colorScheme.primary,
              itemSize: 32.0,
              initialValue: 5.0,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              ratingWidget: RatingWidget(
                full: Icon(Ionicons.star, color: theme.colorScheme.primary),
                half: Icon(
                  Ionicons.star_half,
                  color: theme.colorScheme.primary,
                ),
                empty: Icon(
                  Ionicons.star_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
              unratedColor: theme.colorScheme.onSurfaceVariant,
              decoration: InputDecoration(
                labelText: texts["raiting"]!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<BusinessDetailsCubit, BusinessDetailsState>(
              builder: (context, state) {
                return FilledButton(
                  onPressed: () => handleCreateReview(formKey),
                  child:
                      !state.isReviewLoading
                          ? Text(texts["create-review"]!)
                          : SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                              strokeWidth: 2.0,
                            ),
                          ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    //We show the modal
    showBottomModal(
      body,
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
    );
  }

  //This method is used to handle the creation of a review
  void handleCreateReview(GlobalKey<FormBuilderState> formKey) async {
    var locator = GetIt.instance;
    var texts = locator<AppConstants>().dashBoardTexts["businessDetailsView"]!;
    var uid = locator.get<AuthService>().getUserId();

    //We check if the form is valid
    if (!formKey.currentState!.saveAndValidate()) return;

    //If it is, we get the values
    var values = formKey.currentState!.value;

    //We create the review
    var review = UserReview(
      userId: uid,
      comment: values["comment"],
      rate: values["raiting"],
      businessId: widget.businessId,
      createdAt: DateTime.now(),
    );

    //We create the review
    await context.read<BusinessDetailsCubit>().setReviewToBusiness(review);
    if (!context.mounted) return;

    //We show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texts["review-success-title"]!),
        duration: const Duration(seconds: 4),
      ),
    );

    //We close the modal
    Navigator.pop(context);
  }

  //This method is used to show a bottom modal
  void showBottomModal(Widget body, BoxConstraints constraints) async {
    var theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: constraints,
      backgroundColor: theme.colorScheme.background,
      builder:
          (context) =>
              Padding(padding: MediaQuery.of(context).viewInsets, child: body),
    );

    if (!context.mounted) return;

    //We reset the state of the cubit in case the user closes the modal
    context.read<BusinessDetailsCubit>().resetReviewState();
  }

  //This method is used to create a intent to open any navigation app
  void navigateToBusiness(BuildContext context, texts) {
    context.read<BusinessDetailsCubit>().openUrl(context, texts);
  }

  //This method is used to open the business website
  void openWebsite(String website) {
    context.read<BusinessDetailsCubit>().openWebsite(website);
  }

  //This method is used to call the business
  void callBusiness(String phoneNumber) {
    context.read<BusinessDetailsCubit>().callBusiness(phoneNumber);
  }

  //This method is used to open WhatsApp with the business phone number
  void openWhatsApp(String phoneNumber) {
    context.read<BusinessDetailsCubit>().openWhatsApp(phoneNumber);
  }

  //This method is used to open email client
  void openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Analytics tracking methods - V2 Dashboard-compatible
  void _trackBusinessView(Business business) {
    final analyticsService = GetIt.instance.get<AnalyticsService>();

    // V2: Track using Dashboard-compatible method
    analyticsService.trackDashboardView(
      entityType: 'business',
      entityId: widget.businessId,
      businessId: widget.businessId,
      screen: 'business_details',
    );
  }

  void _trackFavoriteToggle(Business business, bool isFavorite) {
    final analyticsService = GetIt.instance.get<AnalyticsService>();

    // V2: Track using Dashboard-compatible save method
    if (isFavorite) {
      analyticsService.trackDashboardSave(
        entityType: 'business',
        entityId: widget.businessId,
        businessId: widget.businessId,
      );
    }
    // Note: We don't track "unsave" events in V2 schema
  }
}

class _DescriptionWidget extends StatefulWidget {
  final String description;
  final List<String> words;
  final bool shouldTruncate;
  final ThemeData theme;
  final dynamic texts;

  const _DescriptionWidget({
    required this.description,
    required this.words,
    required this.shouldTruncate,
    required this.theme,
    required this.texts,
  });

  @override
  State<_DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<_DescriptionWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: widget.theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.shouldTruncate && !isExpanded
                ? '${widget.words.take(20).join(' ')}...'
                : widget.description,
            style: TextStyle(
              fontSize: widget.theme.textTheme.bodyMedium!.fontSize,
              height: 1.5,
            ),
          ),
          if (widget.shouldTruncate)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => isExpanded = !isExpanded),
                child: Text(
                  isExpanded
                      ? widget.texts["read-less"] ?? "Leer menos"
                      : widget.texts["read-more"] ?? "Leer más",
                ),
              ),
            ),
        ],
      ),
    );
  }
}
