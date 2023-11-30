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
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/models/review_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_details/business_details_cubit.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:heroes_app/src/presentation/widgets/vertical_card_widget.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart' show DateFormat;

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
            return succesView(theme, texts, state);
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
    ThemeData theme,
    texts,
    BusinessDetailsState state,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(state.business!.name)),
        mainCard(
          state.business!,
          theme,
          texts,
          state.isFavourite,
          state.favouriteIsLoading,
        ),
        sectionDoubleTitle(texts, theme, state.allUserReviews),
        commentsList(state.reviews, theme, texts),
        sectionTitle(texts, theme),
        promotionsList(state.promotions, texts),
        const SliverToBoxAdapter(child: SizedBox(height: 16))
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
  ) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: () {},
                  child: Text(texts["navigation-title"]),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: favouriteIsLoading
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
                            color: isFavourite && !favouriteIsLoading
                                ? theme.colorScheme.primary
                                : null,
                          ),
                        ),
                )
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
    ));
  }

  SliverToBoxAdapter sectionDoubleTitle(
      texts, ThemeData theme, List<UserReview> reviews) {
    return SliverToBoxAdapter(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          texts["comments-title"],
          style: theme.textTheme.labelLarge,
        ),
        onTap: () => seeAllComments(theme, texts),
        trailing: Text(texts["comments-button"]!),
      ),
    );
  }

  Widget promotionsList(List<Promotion> promotions, texts) {
    return promotions.isNotEmpty
        ? SliverList.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
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

  Widget commentsList(List<UserReview> comments, ThemeData theme, texts) {
    return SliverToBoxAdapter(
      child: Container(
        height: 174,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: comments.isNotEmpty
            ? ListView.separated(
                padding: const EdgeInsets.all(0.0),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return !(index == comments.length - 1)
                      ? commentCard(theme, comments[index])
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            commentCard(theme, comments[index]),
                            const SizedBox(width: 12),
                            addCommentCard(theme, texts),
                          ],
                        );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 12);
                },
                itemCount: comments.length,
              )
            : emptyCommentsCard(theme, texts),
      ),
    );
  }

  Container emptyCommentsCard(ThemeData theme, texts) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
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
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
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
          )
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
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
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
          )
        ],
      ),
    );
  }

  Widget loadingHeart(ThemeData theme) {
    return SizedBox(
      width: 40,
      child: Stack(children: [
        IconButton.filledTonal(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              theme.colorScheme.background,
            ),
          ),
          onPressed: null,
          icon: const Icon(
            Ionicons.heart_outline,
            color: null,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          ),
        )
      ]),
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
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: state.allUserReviews.isNotEmpty
              ? ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    var theme = Theme.of(context);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.allUserReviews[index].comment,
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "${texts["raiting"]!}: ${state.allUserReviews[index].rate}",
                                  style: theme.textTheme.labelMedium!.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withOpacity(0.9))),
                              Text(
                                  DateFormat("dd/MM/yyyy, hh:mm a", "es")
                                      .format(state
                                          .allUserReviews[index].createdAt),
                                  style: theme.textTheme.labelMedium!.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withOpacity(0.9))),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 16);
                  },
                  itemCount: state.allUserReviews.length)
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  //Methods
  void getBusinessDetails() {
    checkIfBusinessIsMarkedAsFavourite();
    context.read<BusinessDetailsCubit>().getBusinessDetails(widget.businessId);
  }

  void setBusinessAsFavourite() {
    context
        .read<BusinessDetailsCubit>()
        .setBusinessAsFavourite(widget.businessId);
  }

  void checkIfBusinessIsMarkedAsFavourite() {
    context
        .read<BusinessDetailsCubit>()
        .businessIsMarkedAsFavorite(widget.businessId);
  }

  //This method is used to see all the comments of a business
  void seeAllComments(ThemeData theme, texts) {
    context
        .read<BusinessDetailsCubit>()
        .getAllBusinessReviews(widget.businessId);

    //We create the body of the modal
    Widget body = allCommentsBottomModalBody();

    //We show the modal
    showBottomModal(
      body,
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
    );
  }

  void seeRaitingMenu() {
    var locator = GetIt.instance;
    var texts = locator<AppConstants>().dashBoardTexts["businessDetailsView"]!;

    //We create the body of the modal
    var formKey = GlobalKey<FormBuilderState>();
    var theme = Theme.of(context);

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
            Text(
              texts["add-review"]!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: "comment",
              validator: (value) => locator
                  .get<AppMethods>()
                  .emptyStringValidatorWithMaxLength(
                      value, texts["comment-validator"]!, 300),
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
                half:
                    Icon(Ionicons.star_half, color: theme.colorScheme.primary),
                empty: Icon(Ionicons.star_outline,
                    color: theme.colorScheme.primary),
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
                  child: !state.isReviewLoading
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
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: body,
      ),
    );

    if (!context.mounted) return;

    //We reset the state of the cubit in case the user closes the modal
    context.read<BusinessDetailsCubit>().resetReviewState();
  }
}
