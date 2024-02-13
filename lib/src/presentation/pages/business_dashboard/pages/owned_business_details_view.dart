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
import 'package:heroes_app/src/presentation/cubits/manage_business/owned_business_details/owned_business_details_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/async_button_widget.dart';
import 'package:heroes_app/src/presentation/widgets/email_input_widget.dart';
import 'package:heroes_app/src/presentation/widgets/map_preview_widget.dart';
import 'package:heroes_app/src/presentation/widgets/vertical_card_widget.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class OwnedBusinessDetailsView extends StatefulWidget {
  final String businessId;
  const OwnedBusinessDetailsView({super.key, required this.businessId});

  @override
  State<OwnedBusinessDetailsView> createState() =>
      _OwnedBusinessDetailsViewState();
}

class _OwnedBusinessDetailsViewState extends State<OwnedBusinessDetailsView> {
  @override
  void initState() {
    super.initState();
    context.read<OwnedBusinessDetailsCubit>().getInitial();
    context
        .read<OwnedBusinessDetailsCubit>()
        .getBusinessDetails(widget.businessId);
  }

  @override
  Widget build(BuildContext context) {
    final locator = GetIt.instance;
    final texts = locator<AppConstants>()
        .businessDashboardTexts["ownedBusinessDetailsView"];
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        context.read<OwnedBusinessDetailsCubit>().clearState();
        Navigator.of(context).pop();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body:
              BlocBuilder<OwnedBusinessDetailsCubit, OwnedBusinessDetailsState>(
            builder: (context, state) {
              switch (state.status) {
                case BusinessViewCubitStatus.initial:
                  return loadingView(theme, texts);
                case BusinessViewCubitStatus.loading:
                  return loadingView(theme, texts);
                case BusinessViewCubitStatus.success:
                  return succesView(theme, texts, state);
                case BusinessViewCubitStatus.error:
                  return errorView(theme, texts);
                default:
                  return const Center(child: Text('Error'));
              }
            },
          )),
    );
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
    OwnedBusinessDetailsState state,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(state.business!.name),
          actions: [
            IconButton(
              onPressed: () => seeAllBusinessManagers(theme, texts),
              icon: const Icon(Ionicons.people_outline),
            ),
            IconButton(
              onPressed: () => seeAllComments(theme, texts),
              icon: const Icon(Ionicons.chatbubbles_outline),
            ),
            IconButton(
              onPressed: () => seeAddLocationToBusiness(theme, texts),
              icon: const Icon(Ionicons.location_outline),
            ),
            IconButton(
              onPressed: () => seeAllPaymenthMethods(theme, texts),
              icon: const Icon(
                Ionicons.card_outline,
              ),
            ),
          ],
        ),
        mainCard(
          state.business!,
          theme,
          texts,
        ),
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
                subscriptionButton(business, texts),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => seeCreatePromotionView(theme, texts),
                    child: Text(texts["add-promotion-title"]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Builder subscriptionButton(Business business, texts) {
    return Builder(builder: (context) {
      switch (business.subscriptionStatus) {
        case BusinessSubscriptionStatus.active:
          return Expanded(
            child: TextButton(
              onPressed: () => handleSeeSubscriptionDetails(texts),
              child: Text(texts["subscription-active"]!),
            ),
          );
        case BusinessSubscriptionStatus.inactive:
          return Expanded(
            child: FilledButton(
              onPressed: () => handleCreateSubscription(texts),
              child: Text(texts["subscription-inactive"]!),
            ),
          );
        case BusinessSubscriptionStatus.pending:
          return Expanded(
            child: AsyncButtonWidget(
              buttonText: texts["subscription-pending"]!,
              onPressed: () => handleRefreshSubscriptionStatus(),
            ),
          );
        case BusinessSubscriptionStatus.freeTrial:
          return Expanded(
            child: TextButton(
              onPressed: null,
              child: Text(texts["subscription-free-trial"]!),
            ),
          );
        case BusinessSubscriptionStatus.markToRenew:
          return Expanded(
            child: OutlinedButton(
              onPressed: () => handleCreateSubscription(texts),
              child: Text(texts["subscription-mark-to-renew"]!),
            ),
          );
        case BusinessSubscriptionStatus.canceled:
          return Expanded(
            child: TextButton(
              onPressed: () => handleCreateSubscription(texts),
              child: Text(texts["subscription-canceled"]!),
            ),
          );
      }
    });
  }

  SliverToBoxAdapter sectionTitle(texts, ThemeData theme) {
    return SliverToBoxAdapter(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          texts["promotions-title"],
          style: theme.textTheme.labelLarge,
        ),
      ),
    );
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
                    AutoRouter.of(context).push(OwnedPromotionDetailsView(
                        promotion: promotions[index]));
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

  Widget allCommentsBottomModalBody() {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts = locator<AppConstants>().dashBoardTexts["businessDetailsView"]!;

    return BlocBuilder<OwnedBusinessDetailsCubit, OwnedBusinessDetailsState>(
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

  Widget allBusinessManagersBody() {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts = locator<AppConstants>()
        .businessDashboardTexts["ownedBusinessDetailsView"]!;

    return BlocBuilder<OwnedBusinessDetailsCubit, OwnedBusinessDetailsState>(
      builder: (context, state) {
        isEditable(index) =>
            state.business!.ownerUid != state.allManagers[index].uid &&
            locator<AuthService>().getUserId() != state.allManagers[index].uid;

        isOwner(index) =>
            state.business!.ownerUid == state.allManagers[index].uid;

        isManagerCurrentUser(index) =>
            locator<AuthService>().getUserId() == state.allManagers[index].uid;

        return Container(
          color: theme.colorScheme.background,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: state.allManagers.isNotEmpty
                    ? ListView.separated(
                        itemBuilder: (context, index) {
                          var theme = Theme.of(context);
                          return Slidable(
                            endActionPane: isEditable(index)
                                ? ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          handleDeleteManager(
                                              state.allManagers[index].uid,
                                              state.businessId!);
                                        },
                                        label: texts["remove-manager-button"]!,
                                        backgroundColor:
                                            theme.colorScheme.error,
                                        icon: Ionicons.remove_circle_outline,
                                      ),
                                    ],
                                  )
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant
                                      .withOpacity(0.5)),
                              child: ListTile(
                                leading: Icon(
                                  isOwner(index)
                                      ? Ionicons.star_outline
                                      : Ionicons.person_outline,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.9),
                                ),
                                title: Text(
                                    isManagerCurrentUser(index)
                                        ? "Yo"
                                        : "${state.allManagers[index].firstName} ${state.allManagers[index].secondName} ${state.allManagers[index].firstLastName} ${state.allManagers[index].secondLastName}",
                                    style: theme.textTheme.labelLarge),
                                trailing: isEditable(index)
                                    ? Icon(
                                        Ionicons.chevron_back_outline,
                                        color: theme
                                            .colorScheme.onSurfaceVariant
                                            .withOpacity(0.9),
                                      )
                                    : null,
                                subtitle: Text(state.allManagers[index].email),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 16);
                        },
                        itemCount: state.allManagers.length)
                    : const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 4),
              AsyncButtonWidget(
                  buttonText: texts["add-manager-button"]!,
                  onPressed: () async {
                    await hadleAddManager();
                  }),
              const SizedBox(height: 4),
              Text(
                texts["slide-to-remove"]!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  fontSize: theme.textTheme.labelSmall!.fontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget createPromotionBody() {
    var key = GlobalKey<FormBuilderState>();
    var locator = GetIt.instance;

    var texts = locator<AppConstants>()
        .businessDashboardTexts["ownedBusinessDetailsView"]!;
    validateEmptyString(value, message) =>
        locator<AppMethods>().emptyStringValidator(value, message);
    validateEmptyDate(value, message) =>
        locator<AppMethods>().emptyInputValidator(value, message);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                color: Theme.of(context).colorScheme.background,
                padding: const EdgeInsets.only(
                    top: 20, left: 16, right: 16, bottom: 8),
                child: FormBuilder(
                  key: key,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormBuilderTextField(
                        name: "title",
                        validator: (value) =>
                            validateEmptyString(value, texts["empty-value"]!),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: texts["title-label"]!,
                          hintText: texts["title-hint"]!,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: "description",
                        maxLines: 2,
                        validator: (value) =>
                            validateEmptyString(value, texts["empty-value"]!),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: texts["description-label"]!,
                          hintText: texts["description-hint"]!,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: "instructions",
                        maxLines: 2,
                        validator: (value) =>
                            validateEmptyString(value, texts["empty-value"]!),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: texts["instructions-label"]!,
                          hintText: texts["instructions-hint"]!,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderTextField(
                                name: "percentage",
                                keyboardType: TextInputType.number,
                                validator: (value) => validateEmptyString(
                                    value, texts["empty-value"]!),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  labelText: texts["percentage-label"]!,
                                  hintText: texts["percentage-hint"]!,
                                  border: const OutlineInputBorder(),
                                )),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FormBuilderDateTimePicker(
                                name: "expirationDate",
                                inputType: InputType.date,
                                format: DateFormat("dd/MM/yyyy"),
                                validator: (value) => validateEmptyDate(
                                    value, texts["empty-value"]!),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  labelText: texts["expiration-date-label"]!,
                                  hintText: texts["expiration-date-hint"]!,
                                  border: const OutlineInputBorder(),
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      pictureField(texts, Theme.of(context)),
                      const SizedBox(height: 16),
                      AsyncButtonWidget(
                        buttonText: texts["create-button"]!,
                        onPressed: () async {
                          await handleCreatePromotion(key, texts);
                        },
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(texts["cancel-button"]!),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget changeBusinessLocationBody() {
    var key = GlobalKey<FormBuilderState>();
    var locator = GetIt.instance;

    var texts = locator<AppConstants>()
        .businessDashboardTexts["ownedBusinessDetailsView"]!;
    validateEmptyString(value, message) =>
        locator<AppMethods>().emptyStringValidator(value, message);
    var business = context.read<OwnedBusinessDetailsCubit>().state.business!;
    var businessAddress = business.address;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 8),
        child: FormBuilder(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: "address",
                initialValue: businessAddress,
                validator: (value) =>
                    validateEmptyString(value, texts["empty-value"]!),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: texts["address-label"]!,
                  hintText: texts["address-hint"]!,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: MapPreviewWidget(
                  borderRadius: 12,
                  latitude: business.location.latitude,
                  longitude: business.location.longitude,
                ),
              ),
              const SizedBox(height: 16),
              AsyncButtonWidget(
                buttonText: texts["edit-button"]!,
                onPressed: () async {
                  await handleEditAddressAndLocation(key, texts);
                },
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(texts["cancel-button"]!),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget allPaymentMethodsBody() {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts = locator<AppConstants>()
        .businessDashboardTexts["ownedBusinessDetailsView"]!;

    return BlocBuilder<OwnedBusinessDetailsCubit, OwnedBusinessDetailsState>(
      builder: (context, state) {
        return Container(
          color: theme.colorScheme.background,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: state.allPaymentMethods.isNotEmpty
                    ? ListView.separated(
                        itemBuilder: (context, index) {
                          return Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      context
                                          .read<OwnedBusinessDetailsCubit>()
                                          .deletePaymentMethodFromBusiness(
                                              state.allPaymentMethods[index]);
                                    },
                                    label: texts["remove-manager-button"]!,
                                    backgroundColor: theme.colorScheme.error,
                                    icon: Ionicons.remove_circle_outline,
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant
                                      .withOpacity(0.5),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    Ionicons.card_outline,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.9),
                                  ),
                                  title: Text(
                                      "${state.allPaymentMethods[index].brand} ${state.allPaymentMethods[index].lastFourNumbers}",
                                      style: theme.textTheme.labelLarge),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(state
                                          .allPaymentMethods[index].cardHolder),
                                      Text(
                                          "Expira: ${DateFormat("dd/MM/yyyy").format(state.allPaymentMethods[index].expiresAt)}")
                                    ],
                                  ),
                                  trailing: Icon(
                                    Ionicons.chevron_back_outline,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.9),
                                  ),
                                ),
                              ));
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 16);
                        },
                        itemCount: state.allPaymentMethods.length)
                    : Center(child: Text(texts["no-payment-methods"]!)),
              ),
              const SizedBox(height: 4),
              AsyncButtonWidget(
                  buttonText: texts["add-payment-button"]!,
                  onPressed: () async => await handleAddPaymentMethod()),
              const SizedBox(height: 4),
              Text(
                texts["slide-to-remove-payment"]!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  fontSize: theme.textTheme.labelSmall!.fontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  FormBuilderField<Object> pictureField(
      Map<String, String> texts, ThemeData theme) {
    var locator = GetIt.instance;

    return FormBuilderField(
      name: "featured_image",
      builder: (field) {
        return InkWell(
          onTap: () async {
            final picture = await locator.get<AppMethods>().selectPicture();
            if (picture == null) return;
            field.didChange(picture);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 18.0,
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    field.value != null
                        ? texts["featured-img-filled"]!
                        : texts['featured-img-hint']!,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: theme.textTheme.bodyLarge!.fontSize,
                    ),
                  ),
                  Icon(
                    field.value != null
                        ? Ionicons.camera_reverse_outline
                        : Ionicons.image_outline,
                    color: theme.colorScheme.primary,
                  )
                ]),
          ),
        );
      },
    );
  }

  //Methods
  void getBusinessDetails() {
    context
        .read<OwnedBusinessDetailsCubit>()
        .getBusinessDetails(widget.businessId);
  }

  void seeAllComments(ThemeData theme, texts) {
    context
        .read<OwnedBusinessDetailsCubit>()
        .getAllBusinessReviews(widget.businessId);

    //We create the body of the modal
    Widget body = allCommentsBottomModalBody();

    //We show the modal
    showBottomModal(
      body,
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
    );
  }

  void seeAllBusinessManagers(ThemeData theme, texts) {
    context
        .read<OwnedBusinessDetailsCubit>()
        .getAllBusinessManagers(widget.businessId);

    //We create the body of the modal
    Widget body = allBusinessManagersBody();

    //We show the modal
    showBottomModal(
      body,
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
    );
  }

  void seeCreatePromotionView(ThemeData theme, texts) {
    //We create the body of the modal
    Widget body = createPromotionBody();

    //We show the modal
    showBottomModal(
      body,
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 8),
    );
  }

  void seeAddLocationToBusiness(ThemeData theme, texts) {
    //We create the body of the modal
    Widget body = changeBusinessLocationBody();

    //We show the modal
    showBottomModal(
      body,
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 8),
    );
  }

  void seeAllPaymenthMethods(ThemeData theme, texts) {
    //We create the body of the modal
    context
        .read<OwnedBusinessDetailsCubit>()
        .getAllPaymentMethods(widget.businessId);

    Widget body = allPaymentMethodsBody();

    //We show the modal
    showBottomModal(
      body,
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
    );
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
  }

  Future<void> handleCreatePromotion(
      GlobalKey<FormBuilderState> key, texts) async {
    if (!key.currentState!.saveAndValidate()) return;

    Map<String, dynamic> copyOfFields = Map.of(key.currentState!.fields);
    copyOfFields["business_id"] = widget.businessId;

    bool promotionCreated = await context
        .read<OwnedBusinessDetailsCubit>()
        .createPromotion(copyOfFields);

    if (!context.mounted) return;

    if (!promotionCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts["promotion-error"]!),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texts["promotion-created"]!),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> handleDeleteManager(String userUid, String businessId) async {
    final texts = GetIt.instance
        .get<AppConstants>()
        .businessDashboardTexts["ownedBusinessDetailsView"]!;

    final isDeleted = await context
        .read<OwnedBusinessDetailsCubit>()
        .deleteManagerFromBusiness(businessId, userUid);

    if (!context.mounted) return;

    if (isDeleted) {
      //Close the modal
      Navigator.of(context).pop();

      //Show the snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts["manager-deleted"]!),
          duration: const Duration(seconds: 4),
        ),
      );

      return;
    }
    Navigator.of(context).pop();

    //Show the error snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texts["manager-deleted-error"]!),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> hadleAddManager() async {
    var newManagerEmailFormKey = GlobalKey<FormBuilderState>();
    var texts = GetIt.instance
        .get<AppConstants>()
        .businessDashboardTexts["ownedBusinessDetailsView"]!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(texts["add-manager-button"]!),
          content: FormBuilder(
            key: newManagerEmailFormKey,
            child: EmailInputWidget(
              keyName: "email",
              name: "email",
              label: texts["email-label"]!,
              hintText: texts["email-hint"]!,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(texts["cancel-button"]!),
            ),
            AsyncButtonWidget(
              onPressed: () async {
                //First validate the form
                if (!newManagerEmailFormKey.currentState!.saveAndValidate()) {
                  return;
                }

                //Then add the manager
                final managerAdded = await context
                    .read<OwnedBusinessDetailsCubit>()
                    .addManagerToBusiness(
                        newManagerEmailFormKey
                            .currentState!.fields["email"]!.value,
                        context
                            .read<OwnedBusinessDetailsCubit>()
                            .state
                            .businessId!);

                if (!context.mounted) return;

                //Check if the manager was added successfully
                if (managerAdded) {
                  //Close the AlertDialog
                  Navigator.of(context).pop();

                  //Close the bottom modal
                  Navigator.of(context).pop();

                  //Show the snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(texts["manager-added"]!),
                      duration: const Duration(seconds: 4),
                    ),
                  );

                  return;
                } else {
                  //Close the AlertDialog
                  Navigator.of(context).pop();

                  //Close the bottom modal
                  Navigator.of(context).pop();

                  //Show the snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(texts["email-error"]!),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              buttonText: texts["add-button"]!,
            ),
          ],
        );
      },
    );
  }

  Future<void> handleAddPaymentMethod() async {
    var newPaymentMethodFormKey = GlobalKey<FormBuilderState>();
    var texts = GetIt.instance
        .get<AppConstants>()
        .businessDashboardTexts["ownedBusinessDetailsView"]!;
    context.read<OwnedBusinessDetailsCubit>().getAcceptanceToken();

    var theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BlocBuilder<OwnedBusinessDetailsCubit,
            OwnedBusinessDetailsState>(builder: (context, state) {
          return AlertDialog(
            title: Text(texts["add-payment-button"]!),
            content: FormBuilder(
              key: newPaymentMethodFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: "card_holder",
                    //MIn 5 max 128
                    validator: (value) => GetIt.instance<AppMethods>()
                        .cardHolderNameValidator(value, texts["empty-value"]!),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLength: 128,
                    decoration: InputDecoration(
                      labelText: texts["card-holder-label"]!,
                      hintText: texts["card-holder-hint"]!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FormBuilderTextField(
                    name: "number",
                    maxLength: 16,
                    keyboardType: TextInputType.number,
                    validator: (value) => GetIt.instance<AppMethods>()
                        .emptyStringValidator(value, texts["empty-value"]!),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: texts["card-number-label"]!,
                      hintText: texts["card-number-hint"]!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: "exp_year",
                          maxLength: 2,
                          keyboardType: TextInputType.datetime,
                          validator: (value) => GetIt.instance<AppMethods>()
                              .cardYearValidator(value, texts["empty-value"]!),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText: texts["card-expiration-year-label"]!,
                            hintText: texts["card-expiration-year-hint"]!,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FormBuilderTextField(
                          maxLength: 2,
                          name: "exp_month",
                          keyboardType: TextInputType.datetime,
                          validator: (value) => GetIt.instance<AppMethods>()
                              .cardMonthValidator(value, texts["empty-value"]!),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText: texts["card-expiration-month-label"]!,
                            hintText: texts["card-expiration-month-hint"]!,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FormBuilderTextField(
                    name: "cvc",
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                    validator: (value) => GetIt.instance<AppMethods>()
                        .cvvValidator(value, texts["empty-value"]!),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: texts["card-cvv-label"]!,
                      hintText: texts["card-cvv-hint"]!,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: context
                            .read<OwnedBusinessDetailsCubit>()
                            .state
                            .userAcceptedTerms,
                        onChanged: (value) => context
                            .read<OwnedBusinessDetailsCubit>()
                            .changeUserAcceptedTerms(value!),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => launchUrl(Uri.parse(context
                              .read<OwnedBusinessDetailsCubit>()
                              .state
                              .acceptanceData["permalink"])),
                          child: Text(
                            texts["accept-terms"]!,
                            style: TextStyle(
                                fontSize: theme.textTheme.labelSmall!.fontSize),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(texts["cancel-button"]!),
              ),
              context.read<OwnedBusinessDetailsCubit>().state.userAcceptedTerms
                  ? AsyncButtonWidget(
                      buttonText: texts["add-button"]!,
                      onPressed: () async {
                        //First validate the form
                        if (!newPaymentMethodFormKey.currentState!
                            .saveAndValidate()) {
                          return;
                        }
                        //Then we create the payment method
                        final cardData =
                            newPaymentMethodFormKey.currentState!.value;
                        await context
                            .read<OwnedBusinessDetailsCubit>()
                            .createCardToken(cardData, context);
                      },
                    )
                  : FilledButton(
                      onPressed: null,
                      child: Text(texts["add-button"]!),
                    ),
            ],
          );
        });
      },
    );
  }

  Future<void> handleEditAddressAndLocation(
      GlobalKey<FormBuilderState> key, texts) async {
    if (!key.currentState!.saveAndValidate()) return;

    var businessAddress = key.currentState!.fields["address"]!.value;

    final isAddressEdited = await context
        .read<OwnedBusinessDetailsCubit>()
        .setAddressToBusiness(businessAddress);

    if (!context.mounted) return;
    if (isAddressEdited) {
      //Close the modal
      Navigator.of(context).pop();

      //Show the snackbar if the address was edited
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts["address-edited"]!),
          duration: const Duration(seconds: 4),
        ),
      );

      return;
    } else {
      //We set error to the address field
      key.currentState!.fields["address"]!.invalidate(texts["address-error"]!);
    }
  }

  Future<void> handleCreateSubscription(texts) async {
    //First we get the payment methods
    context
        .read<OwnedBusinessDetailsCubit>()
        .getAllPaymentMethods(widget.businessId);

    showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return BlocBuilder<OwnedBusinessDetailsCubit,
              OwnedBusinessDetailsState>(
            builder: (context, state) {
              final paymentMethods = state.allPaymentMethods;
              var selectedPaymentMethodId = state.selectedPaymentMethod;

              return AlertDialog(
                title: Text(texts["select-payment"]!),
                content: paymentMethods.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          Text(texts["valid-cards"]!),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 1,
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return paymentMethods[index]
                                            .expiresAt
                                            .isAfter(DateTime.now()) &&
                                        paymentMethods[index].paymentMethodId !=
                                            null
                                    ? RadioListTile(
                                        value: paymentMethods[index].id,
                                        groupValue: selectedPaymentMethodId,
                                        onChanged: (value) {
                                          if (value == null) return;
                                          context
                                              .read<OwnedBusinessDetailsCubit>()
                                              .setSelectedPaymentMethod(
                                                  paymentMethods[index].id);
                                        },
                                        title: Text(
                                            "${paymentMethods[index].brand} ${paymentMethods[index].lastFourNumbers}"),
                                      )
                                    : const SizedBox();
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 16);
                              },
                              itemCount: paymentMethods.length,
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 1,
                        child:
                            Center(child: Text(texts["no-payment-methods"]!)),
                      ),
                actions: [
                  state.selectedPaymentMethod != ""
                      ? AsyncButtonWidget(
                          buttonText: texts["create-subscription"]!,
                          onPressed: () => createSubscription(texts),
                        )
                      : FilledButton(
                          onPressed: null,
                          child: Text(texts["create-subscription"]!),
                        ),
                ],
              );
            },
          );
        });
  }

  Future<void> handleSeeSubscriptionDetails(texts) async {
    context.read<OwnedBusinessDetailsCubit>().getLatestTransaction();

    showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) {
          return BlocBuilder<OwnedBusinessDetailsCubit,
              OwnedBusinessDetailsState>(
            builder: (context, state) {
              return SizedBox(
                child: AlertDialog(
                  title: Text(texts["subscription-details"]!),
                  content: state.latestTransaction != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(texts["subscription-type"]! +
                                ": " +
                                state.latestTransaction!.plan),
                            Text(texts["subscription-creation-date"]! +
                                ": ${DateFormat("dd/MM/yyyy").format(state.latestTransaction!.createdAt)}"),
                            Text(texts["subscription-expiration-date"]! +
                                ": ${DateFormat("dd/MM/yyyy").format(state.latestTransaction!.expirationDate)}"),
                          ],
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                  actions: [
                    TextButton(
                      onPressed: () => cancelSubscription(texts),
                      child: Text(texts["cancel-subscription"]!),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(texts["cancel-button"]!),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Future<void> handleRefreshSubscriptionStatus() async {
    await context.read<OwnedBusinessDetailsCubit>().refreshSubscriptionStatus();
  }

  void createScaffoldMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> createSubscription(texts) async {
    final subscriptionCreated =
        await context.read<OwnedBusinessDetailsCubit>().createSubscription();
    if (subscriptionCreated) {
      if (!context.mounted) return;

      //We refresh the business details
      context
          .read<OwnedBusinessDetailsCubit>()
          .getBusinessDetails(widget.businessId);
      Navigator.of(context).pop();
      createScaffoldMessage(texts["subscription-created"]!);
    } else {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      createScaffoldMessage(texts["create-subscription-error"]!);
    }
  }

  Future<void> cancelSubscription(texts) async {
    await context.read<OwnedBusinessDetailsCubit>().cancelSubscription();
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}
