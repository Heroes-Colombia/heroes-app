import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/locator.dart';
import 'package:heroes_app/src/presentation/cubits/manage_business/owned_business_details/owned_business_details_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/manage_business/owned_businesses/owned_businesses_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/async_button_widget.dart';
import 'package:heroes_app/src/presentation/widgets/email_input_widget.dart';
import 'package:heroes_app/src/presentation/widgets/map_picker_widget.dart';
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
        .getBusinessDetails(widget.businessId)
        .then((value) {
          final currentBusiness =
              context.read<OwnedBusinessDetailsCubit>().state.business!;
          final texts =
              GetIt.instance<AppConstants>()
                  .businessDashboardTexts["ownedBusinessDetailsView"];
          final paymentMethods =
              context.read<OwnedBusinessDetailsCubit>().state.allPaymentMethods;

          //On the first load we check if the subscription status is pending to refresh the status
          if (currentBusiness.subscriptionStatus ==
              BusinessSubscriptionStatus.pending) {
            context
                .read<OwnedBusinessDetailsCubit>()
                .refreshSubscriptionStatus();
          }

          //On the first load we check if the user has a free trial to show the dialog
          if (currentBusiness.subscriptionStatus ==
                  BusinessSubscriptionStatus.freeTrial &&
              paymentMethods.isEmpty) {
            showFreeTrialDialog(context, currentBusiness, texts);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final locator = GetIt.instance;
    final texts =
        locator<AppConstants>()
            .businessDashboardTexts["ownedBusinessDetailsView"];
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<OwnedBusinessDetailsCubit>().clearState();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<OwnedBusinessDetailsCubit, OwnedBusinessDetailsState>(
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
    OwnedBusinessDetailsState state,
  ) {
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
          actions: [
            IconButton(
              onPressed: () => seeAllBusinessManagers(theme, texts),
              icon: const Icon(Ionicons.people_outline),
            ),
            IconButton(
              onPressed: () => seeAllPaymenthMethods(theme, texts),
              icon: const Icon(Ionicons.card_outline),
            ),
            IconButton(
              onPressed: () => seeEditBusinessInformation(theme, texts),
              icon: const Icon(Ionicons.settings_outline),
            ),
          ],
        ),
        mainCard(state.business!, theme, texts),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverFillRemaining(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(text: texts["promotions-title"] ?? ""),
                    Tab(text: texts["information-title"] ?? ""),
                    Tab(text: texts["comments-title"] ?? ""),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      promotionsList(state.promotions, texts, theme),
                      informationList(state.business, theme, texts),
                      allCommentsBottomModalBody(),
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
  SliverToBoxAdapter mainCard(Business business, ThemeData theme, texts) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () async {
                final newPicture = await _showImagePickerDialog(
                  context,
                  texts,
                  theme,
                );
                if (newPicture != null) {
                  if (!mounted) return;
                  await context
                      .read<OwnedBusinessDetailsCubit>()
                      .handleEditFeaturedImage(newPicture);
                }
                if (!mounted) return;
                context.read<OwnedBusinessesCubit>().getOwnedBusinesses();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      business.featuredImage.isNotEmpty
                          ? Image.network(
                            business.featuredImage,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          )
                          : Image.asset(
                            'assets/images/file-not-found.png',
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                ),
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
    return Builder(
      builder: (context) {
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
              child: FilledButton(
                onPressed: () => handleAddPaymentMethod(),
                child: Text(texts["subscription-free-trial"]!),
              ),
            );
          case BusinessSubscriptionStatus.markToRenew:
            return Expanded(
              child: TextButton(
                onPressed: () => handleSeeSubscriptionDetails(texts),
                child: Text(texts["subscription-active"]!),
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
      },
    );
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

  Widget promotionsList(List<Promotion> promotions, texts, ThemeData theme) {
    return promotions.isNotEmpty
        ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              promotions
                      .where(
                        (element) => element.expiredAt.isAfter(DateTime.now()),
                      )
                      .isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: Text(
                      texts["active-promotions"],
                      style: theme.textTheme.labelSmall,
                    ),
                  )
                  : const SizedBox.shrink(),
              const SizedBox(height: 16),
              SizedBox(
                height:
                    (promotions
                                .where(
                                  (element) =>
                                      element.expiredAt.isAfter(DateTime.now()),
                                )
                                .length /
                            2)
                        .ceil() *
                    186,
                child: GridView.count(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children:
                      promotions
                          .where(
                            (element) =>
                                element.expiredAt.isAfter(DateTime.now()),
                          )
                          .map((promotion) => promotionCard(promotion, theme))
                          .toList(),
                ),
              ),
              promotions
                      .where(
                        (element) => element.expiredAt.isBefore(DateTime.now()),
                      )
                      .isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: Text(
                      texts["inactive-promotions"],
                      style: theme.textTheme.labelSmall,
                    ),
                  )
                  : const SizedBox.shrink(),
              SizedBox(
                height:
                    (promotions
                                .where(
                                  (element) => element.expiredAt.isBefore(
                                    DateTime.now(),
                                  ),
                                )
                                .length /
                            2)
                        .ceil() *
                    196,
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children:
                      promotions
                          .where(
                            (element) =>
                                element.expiredAt.isBefore(DateTime.now()),
                          )
                          .map((promotion) => promotionCard(promotion, theme))
                          .toList(),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
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

  GestureDetector promotionCard(Promotion promotion, theme) {
    return GestureDetector(
      onTap:
          () => AutoRouter.of(
            context,
          ).push(OwnedPromotionDetailsView(promotion: promotion)),
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
                    height: 108,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: theme.textTheme.labelLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                promotion.description,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: theme.textTheme.labelLarge!.fontSize,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget informationList(Business? business, ThemeData theme, texts) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              child: InkWell(
                onTap: () {
                  seeAddLocationToBusiness(theme, texts);
                },
                child: MapPreviewWidget(
                  borderRadius: 20,
                  latitude: business.location.latitude,
                  longitude: business.location.longitude,
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => seeAddLocationToBusiness(theme, texts),
              child: Text(texts["edit-address-button"]!),
            ),
          ],
        );
      },
    );
  }

  Widget allCommentsBottomModalBody() {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts =
        locator<AppConstants>()
            .businessDashboardTexts["ownedBusinessDetailsView"]!;

    return BlocBuilder<OwnedBusinessDetailsCubit, OwnedBusinessDetailsState>(
      builder: (context, state) {
        return Container(
          color: theme.colorScheme.background,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child:
              state.allUserReviews.isNotEmpty
                  ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      var theme = Theme.of(context);
                      return Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${texts["raiting"]!}: ${state.allUserReviews[index].rate}",
                                  style: theme.textTheme.labelMedium!.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
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
                                  style: theme.textTheme.labelMedium!.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
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
                        ],
                      );
                    },
                    itemCount: 1,
                  ),
        );
      },
    );
  }

  Widget editBusinessInformationModalBody(
    GlobalKey<FormBuilderState> editInfoKey,
  ) {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts =
        locator<AppConstants>()
            .businessDashboardTexts["ownedBusinessDetailsView"]!;
    return BlocBuilder<OwnedBusinessDetailsCubit, OwnedBusinessDetailsState>(
      builder: (context, state) {
        final business = state.business!;
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            color: theme.colorScheme.background,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: FormBuilder(
                key: editInfoKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormBuilderTextField(
                      name: "name",
                      initialValue: business.name,
                      validator:
                          (value) => locator<AppMethods>().emptyStringValidator(
                            value,
                            texts["empty-value"]!,
                          ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: texts['business-name-label']!,
                        hintText: texts['business-name-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: "owner_name",
                      initialValue: business.ownerName,
                      validator:
                          (value) => locator<AppMethods>().emptyStringValidator(
                            value,
                            texts["empty-value"]!,
                          ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: texts['business-ownerName-label']!,
                        hintText: texts['business-ownerName-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: "email",
                      initialValue: business.email,
                      validator:
                          (value) => locator<AppMethods>().emptyStringValidator(
                            value,
                            texts["empty-value"]!,
                          ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: texts['business-email-label']!,
                        hintText: texts['business-email-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: "phone_number",
                      initialValue: business.phoneNumber,
                      keyboardType: TextInputType.phone,
                      validator:
                          (value) => locator<AppMethods>().emptyStringValidator(
                            value,
                            texts["empty-value"]!,
                          ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: texts['business-phoneNumber-label']!,
                        hintText: texts['business-phoneNumber-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: "identification",
                      initialValue: business.identification,
                      keyboardType: TextInputType.phone,
                      validator:
                          (value) => locator<AppMethods>().emptyStringValidator(
                            value,
                            texts["empty-value"]!,
                          ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: texts['business-identification-label']!,
                        hintText: texts['business-identification-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    pictureField(texts, Theme.of(context), 'business'),
                    const SizedBox(height: 16),
                    FormBuilderField(
                      initialValue: business.categories,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? texts["empty-value"]!
                                  : null,
                      builder:
                          (field) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                texts["business-category-label"]!,
                                style: theme.textTheme.labelLarge,
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    field.value!
                                        .map(
                                          (e) => ChoiceChip(
                                            selected: false,
                                            onSelected:
                                                (value) => context
                                                    .read<
                                                      OwnedBusinessDetailsCubit
                                                    >()
                                                    .handleRemoveSelectedCategory(
                                                      e,
                                                      field,
                                                    ),
                                            padding: const EdgeInsets.all(12),
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  state.allCategories
                                                      .firstWhere(
                                                        (element) =>
                                                            element.id == e,
                                                      )
                                                      .name,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text("x"),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                              const SizedBox(height: 8),
                              FormBuilderDropdown(
                                name: "",
                                onChanged:
                                    (value) => context
                                        .read<OwnedBusinessDetailsCubit>()
                                        .handleSetSelectedCategory(
                                          value!,
                                          field,
                                        ),
                                items:
                                    state.allCategories.map((category) {
                                      return DropdownMenuItem(
                                        value: category.id,
                                        child: Row(
                                          children: [
                                            SvgPicture.network(
                                              category.imageUrl,
                                              width: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(category.name),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: texts["business-category-hint"]!,
                                ),
                              ),
                            ],
                          ),
                      name: "categories",
                    ),
                    const SizedBox(height: 16),
                    AsyncButtonWidget(
                      onPressed: () async {
                        final success = await context
                            .read<OwnedBusinessDetailsCubit>()
                            .handleEditBusinessInformation(editInfoKey);
                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(texts["business-updated-success"]!),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      buttonText: texts["edit-button"]!,
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(texts["cancel-button"]!),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget allBusinessManagersBody() {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts =
        locator<AppConstants>()
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
                child:
                    state.allManagers.isNotEmpty
                        ? ListView.separated(
                          itemBuilder: (context, index) {
                            var theme = Theme.of(context);
                            return Slidable(
                              endActionPane:
                                  isEditable(index)
                                      ? ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) {
                                              handleDeleteManager(
                                                state.allManagers[index].uid,
                                                state.businessId!,
                                              );
                                            },
                                            label:
                                                texts["remove-manager-button"]!,
                                            backgroundColor:
                                                theme.colorScheme.error,
                                            icon:
                                                Ionicons.remove_circle_outline,
                                          ),
                                        ],
                                      )
                                      : null,
                              child: Container(
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
                                    style: theme.textTheme.labelLarge,
                                  ),
                                  trailing:
                                      isEditable(index)
                                          ? Icon(
                                            Ionicons.chevron_back_outline,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withOpacity(0.9),
                                          )
                                          : null,
                                  subtitle: Text(
                                    state.allManagers[index].email,
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemCount: state.allManagers.length,
                        )
                        : Center(child: Text(texts["no-managers"]!)),
              ),
              const SizedBox(height: 4),
              AsyncButtonWidget(
                buttonText: texts["add-manager-button"]!,
                onPressed: () async {
                  await hadleAddManager();
                },
              ),
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

    var texts =
        locator<AppConstants>()
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
                  top: 20,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: FormBuilder(
                  key: key,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormBuilderTextField(
                        name: "title",
                        validator:
                            (value) => validateEmptyString(
                              value,
                              texts["empty-value"]!,
                            ),
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
                        validator:
                            (value) => validateEmptyString(
                              value,
                              texts["empty-value"]!,
                            ),
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
                        validator:
                            (value) => validateEmptyString(
                              value,
                              texts["empty-value"]!,
                            ),
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
                              validator:
                                  (value) => validateEmptyString(
                                    value,
                                    texts["empty-value"]!,
                                  ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                labelText: texts["percentage-label"]!,
                                hintText: texts["percentage-hint"]!,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FormBuilderDateTimePicker(
                              name: "expirationDate",
                              inputType: InputType.date,
                              format: DateFormat("dd/MM/yyyy"),
                              validator:
                                  (value) => validateEmptyDate(
                                    value,
                                    texts["empty-value"]!,
                                  ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                labelText: texts["expiration-date-label"]!,
                                hintText: texts["expiration-date-hint"]!,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      pictureField(texts, Theme.of(context), 'promotion'),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget changeBusinessLocationBody() {
    var key = GlobalKey<FormBuilderState>();
    var locator = GetIt.instance;

    var texts =
        locator<AppConstants>()
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
                validator:
                    (value) =>
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
                child: MapPickerWidget(
                  borderRadius: 12,
                  latitude: business.location.latitude,
                  longitude: business.location.longitude,
                  onLocationChanged:
                      (double? latitude, double? longitude) =>
                          locationToAddress(key, latitude, longitude),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget allPaymentMethodsBody() {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts =
        locator<AppConstants>()
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
                child:
                    state.allPaymentMethods.isNotEmpty
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
                                            state.allPaymentMethods[index],
                                          );
                                    },
                                    label: texts["remove-manager-button"]!,
                                    backgroundColor: theme.colorScheme.error,
                                    icon: Ionicons.remove_circle_outline,
                                  ),
                                ],
                              ),
                              child: Container(
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
                                child: ListTile(
                                  leading: Icon(
                                    Ionicons.card_outline,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.9),
                                  ),
                                  title: Text(
                                    "${state.allPaymentMethods[index].brand} ${state.allPaymentMethods[index].lastFourNumbers}",
                                    style: theme.textTheme.labelLarge,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state
                                            .allPaymentMethods[index]
                                            .cardHolder,
                                      ),
                                      Text(
                                        "Expira: ${DateFormat("dd/MM/yyyy").format(state.allPaymentMethods[index].expiresAt)}",
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Ionicons.chevron_back_outline,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.9),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemCount: state.allPaymentMethods.length,
                        )
                        : Center(child: Text(texts["no-payment-methods"]!)),
              ),
              const SizedBox(height: 4),
              AsyncButtonWidget(
                buttonText: texts["add-payment-button"]!,
                onPressed: () async => await handleAddPaymentMethod(),
              ),
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
    Map<String, String> texts,
    ThemeData theme,
    String? type,
  ) {
    return FormBuilderField(
      name: "featured_image",
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final picture = await _showImagePickerDialog(
                  context,
                  texts,
                  theme,
                );
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
                          : type == 'business'
                          ? texts['business-img-hint']!
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
                    ),
                  ],
                ),
              ),
            ),
            if (field.value != null) ...[
              const SizedBox(height: 8),
              Text(
                texts["featured-img-uploaded-success"]!,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: theme.textTheme.bodySmall!.fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File((field.value as XFile).path),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  //Method to show the image picker dialog
  //This method is used to show a dialog with options to take a picture or select one
  //It returns the selected image as an XFile
  Future<XFile?> _showImagePickerDialog(
    BuildContext context,
    Map<String, String> texts,
    ThemeData theme,
  ) async {
    return await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(texts['business-img-hint']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Ionicons.camera_outline),
                title: Text(texts["business-img-take-picture"]!),
                onTap: () async {
                  final picture = await locator.get<AppMethods>().takePicture();
                  Navigator.of(context).pop(picture);
                },
              ),
              ListTile(
                leading: Icon(Ionicons.image_outline),
                title: Text(texts["business-img-select-from-gallery"]!),
                onTap: () async {
                  final picture =
                      await locator.get<AppMethods>().selectPicture();
                  Navigator.of(context).pop(picture);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(texts['cancel'] ?? 'Cancel'),
            ),
          ],
        );
      },
    );
  }

  //Methods
  void getBusinessDetails() {
    context.read<OwnedBusinessDetailsCubit>().getBusinessDetails(
      widget.businessId,
    );
  }

  void seeEditBusinessInformation(ThemeData theme, texts) {
    final editInfoKey = GlobalKey<FormBuilderState>();

    //We create the body of the modal
    Widget body = editBusinessInformationModalBody(editInfoKey);

    //We show the modal
    showBottomModal(
      body,
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
    );
  }

  void seeAllBusinessManagers(ThemeData theme, texts) {
    context.read<OwnedBusinessDetailsCubit>().getAllBusinessManagers(
      widget.businessId,
    );

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
      enableDrag: false,
    );
  }

  void seeAllPaymenthMethods(ThemeData theme, texts) {
    //We create the body of the modal
    context.read<OwnedBusinessDetailsCubit>().getAllPaymentMethods(
      widget.businessId,
    );

    Widget body = allPaymentMethodsBody();

    //We show the modal
    showBottomModal(
      body,
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
    );
  }

  void showBottomModal(
    Widget body,
    BoxConstraints constraints, {
    bool enableDrag = true,
  }) async {
    var theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      enableDrag: enableDrag,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: constraints,
      backgroundColor: theme.colorScheme.background,
      builder:
          (context) =>
              Padding(padding: MediaQuery.of(context).viewInsets, child: body),
    );
  }

  void showFreeTrialDialog(BuildContext context, Business business, texts) {
    //After we build the widget we show the dialog if the is on free trial
    SchedulerBinding.instance.addPostFrameCallback((_) {
      business.subscriptionStatus == BusinessSubscriptionStatus.freeTrial
          ? showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(texts["free-trial-title"]!),
                content: Text(texts["free-trial-description"]!),
                actions: [
                  FilledButton(
                    onPressed: () => handleAddPaymentMethod(),
                    child: Text(texts["add-payment-button"]!),
                  ),
                ],
              );
            },
          )
          : null;
    });
  }

  Future<void> handleCreatePromotion(
    GlobalKey<FormBuilderState> key,
    texts,
  ) async {
    if (!key.currentState!.saveAndValidate()) return;

    Map<String, dynamic> copyOfFields = Map.of(key.currentState!.fields);
    copyOfFields["business_id"] = widget.businessId;

    bool promotionCreated = await context
        .read<OwnedBusinessDetailsCubit>()
        .createPromotion(copyOfFields);

    if (!context.mounted) return;

    if (!promotionCreated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(texts["promotion-error"]!)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texts["promotion-created"]!)));
    Navigator.of(context).pop();
  }

  Future<void> handleDeleteManager(String userUid, String businessId) async {
    final texts =
        GetIt.instance
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
    var texts =
        GetIt.instance
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

                await context
                    .read<OwnedBusinessDetailsCubit>()
                    .addManagerToBusiness(
                      newManagerEmailFormKey
                          .currentState!
                          .fields["email"]!
                          .value,
                      context
                          .read<OwnedBusinessDetailsCubit>()
                          .state
                          .businessId!,
                      context,
                      texts,
                    );
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
    var texts =
        GetIt.instance
            .get<AppConstants>()
            .businessDashboardTexts["ownedBusinessDetailsView"]!;
    context.read<OwnedBusinessDetailsCubit>().getAcceptanceToken();

    var theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BlocBuilder<
          OwnedBusinessDetailsCubit,
          OwnedBusinessDetailsState
        >(
          builder: (context, state) {
            return AlertDialog(
              title: Text(texts["add-payment-button"]!),
              content: FormBuilder(
                key: newPaymentMethodFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderTextField(
                        name: "card_holder",
                        //MIn 5 max 128
                        validator:
                            (value) => GetIt.instance<AppMethods>()
                                .cardHolderNameValidator(
                                  value,
                                  texts["empty-value"]!,
                                ),
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
                        validator:
                            (value) => GetIt.instance<AppMethods>()
                                .emptyStringValidator(
                                  value,
                                  texts["empty-value"]!,
                                ),
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
                              maxLength: 2,
                              name: "exp_month",
                              keyboardType: TextInputType.datetime,
                              validator:
                                  (value) => GetIt.instance<AppMethods>()
                                      .cardMonthValidator(
                                        value,
                                        texts["empty-value"]!,
                                      ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                labelText:
                                    texts["card-expiration-month-label"]!,
                                hintText: texts["card-expiration-month-hint"]!,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FormBuilderTextField(
                              name: "exp_year",
                              maxLength: 2,
                              keyboardType: TextInputType.datetime,
                              validator:
                                  (value) => GetIt.instance<AppMethods>()
                                      .cardYearValidator(
                                        value,
                                        texts["empty-value"]!,
                                      ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                labelText: texts["card-expiration-year-label"]!,
                                hintText: texts["card-expiration-year-hint"]!,
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
                        validator:
                            (value) => GetIt.instance<AppMethods>()
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
                            value:
                                context
                                    .read<OwnedBusinessDetailsCubit>()
                                    .state
                                    .userAcceptedTerms,
                            onChanged:
                                (value) => context
                                    .read<OwnedBusinessDetailsCubit>()
                                    .changeUserAcceptedTerms(value!),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () => launchUrl(
                                    Uri.parse(
                                      context
                                          .read<OwnedBusinessDetailsCubit>()
                                          .state
                                          .acceptanceData["permalink"],
                                    ),
                                  ),
                              child: Text(
                                texts["accept-terms"]!,
                                style: TextStyle(
                                  fontSize:
                                      theme.textTheme.labelSmall!.fontSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(texts["cancel-button"]!),
                ),
                context
                        .read<OwnedBusinessDetailsCubit>()
                        .state
                        .userAcceptedTerms
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
          },
        );
      },
    );
  }

  Future<void> locationToAddress(
    GlobalKey<FormBuilderState> key,
    double? latitude,
    double? longitude,
  ) async {
    final newAddress = await locator<AppMethods>().getAddressFromCoordinates(
      latitude!,
      longitude!,
    );

    key.currentState!.fields["address"]!.didChange(newAddress);
  }

  Future<void> handleEditAddressAndLocation(
    GlobalKey<FormBuilderState> key,
    texts,
  ) async {
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
    context.read<OwnedBusinessDetailsCubit>().getAllPaymentMethods(
      widget.businessId,
    );

    showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return BlocBuilder<
          OwnedBusinessDetailsCubit,
          OwnedBusinessDetailsState
        >(
          builder: (context, state) {
            final paymentMethods = state.allPaymentMethods;
            var selectedPaymentMethodId = state.selectedPaymentMethod;

            return AlertDialog(
              title: Text(texts["select-payment"]!),
              content:
                  paymentMethods.isNotEmpty
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
                                return paymentMethods[index].expiresAt.isAfter(
                                          DateTime.now(),
                                        ) &&
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
                                              paymentMethods[index].id,
                                            );
                                      },
                                      title: Text(
                                        "${paymentMethods[index].brand} ${paymentMethods[index].lastFourNumbers}",
                                      ),
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
                        child: Center(
                          child: Text(texts["no-payment-methods"]!),
                        ),
                      ),
              actions: [
                state.allPaymentMethods.isEmpty
                    ? TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        seeAllPaymenthMethods(Theme.of(context), texts);
                      },
                      child: Text(texts["add-payment-button"]!),
                    )
                    : const SizedBox.shrink(),
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
      },
    );
  }

  Future<void> handleSeeSubscriptionDetails(texts) async {
    context.read<OwnedBusinessDetailsCubit>().getLatestTransaction();

    showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return BlocBuilder<
          OwnedBusinessDetailsCubit,
          OwnedBusinessDetailsState
        >(
          builder: (context, state) {
            return SizedBox(
              child: AlertDialog(
                title: Text(texts["subscription-details"]!),
                content:
                    state.latestTransaction != null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              texts["subscription-type"]! +
                                  ": " +
                                  state.latestTransaction!.plan,
                            ),
                            Text(
                              texts["subscription-creation-date"]! +
                                  ": ${DateFormat("dd/MM/yyyy").format(state.latestTransaction!.createdAt)}",
                            ),
                            Text(
                              texts["subscription-expiration-date"]! +
                                  ": ${DateFormat("dd/MM/yyyy").format(state.latestTransaction!.expirationDate)}",
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(texts["renew-subscription"]!),
                                !state.isSubscriptionLoading
                                    ? Switch(
                                      value:
                                          state.business!.subscriptionStatus ==
                                                  BusinessSubscriptionStatus
                                                      .markToRenew
                                              ? true
                                              : false,
                                      onChanged: ((value) {
                                        context
                                            .read<OwnedBusinessDetailsCubit>()
                                            .markSubscriptionToAutomaticRenewal(
                                              value,
                                            );
                                      }),
                                    )
                                    : Switch(
                                      value:
                                          !(state
                                                  .business!
                                                  .subscriptionStatus ==
                                              BusinessSubscriptionStatus
                                                  .markToRenew),
                                      onChanged: null,
                                    ),
                              ],
                            ),
                          ],
                        )
                        : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(texts["cancel-button"]!),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> handleRefreshSubscriptionStatus() async {
    await context.read<OwnedBusinessDetailsCubit>().refreshSubscriptionStatus();
  }

  void createScaffoldMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> createSubscription(texts) async {
    final subscriptionCreated =
        await context.read<OwnedBusinessDetailsCubit>().createSubscription();
    if (subscriptionCreated) {
      if (!context.mounted) return;

      //We refresh the business details
      context.read<OwnedBusinessDetailsCubit>().getBusinessDetails(
        widget.businessId,
      );
      Navigator.of(context).pop();
      createScaffoldMessage(texts["subscription-created"]!);
    } else {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      createScaffoldMessage(texts["create-subscription-error"]!);
    }
  }
}
