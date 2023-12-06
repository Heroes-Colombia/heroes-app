import 'package:flutter/material.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/presentation/widgets/async_text_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/presentation/cubits/manage_business/owned_business_details/owned_business_details_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/async_button_widget.dart';
import 'package:intl/intl.dart';

@RoutePage()
class OwnedPromotionDetailsView extends StatelessWidget {
  final Promotion promotion;
  const OwnedPromotionDetailsView({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    var locator = GetIt.instance;
    var texts =
        locator.get<AppConstants>().dashBoardTexts['promotionDetailsView']!;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(title: Text(promotion.title)),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 24, top: 12),
                child: SizedBox(
                  height: 300,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: promotion.featuredImage.isNotEmpty
                        ? Image.network(
                            promotion.featuredImage,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            editPromotionBody(context, promotion, texts),
          ],
        ),
      ),
    );
  }

  Widget editPromotionBody(BuildContext context, Promotion promotion, texts) {
    var key = GlobalKey<FormBuilderState>();
    var locator = GetIt.instance;

    var texts = locator<AppConstants>()
        .businessDashboardTexts["ownedBusinessDetailsView"]!;
    validateEmptyString(value, message) =>
        locator<AppMethods>().emptyStringValidator(value, message);
    validateEmptyDate(value, message) =>
        locator<AppMethods>().emptyInputValidator(value, message);

    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: FormBuilder(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderDropdown(
                  name: "status",
                  initialValue: promotion.status,
                  decoration: InputDecoration(
                    labelText: texts["status-label"]!,
                    hintText: texts["status-hint"]!,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: PromotionStatus.active,
                      child: Text(texts["active"]!),
                    ),
                    DropdownMenuItem(
                      value: PromotionStatus.pending,
                      child: Text(texts["pending"]!),
                    ),
                    DropdownMenuItem(
                      value: PromotionStatus.inactive,
                      child: Text(texts["inactive"]!),
                    ),
                  ]),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: "title",
                validator: (value) =>
                    validateEmptyString(value, texts["empty-value"]!),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: promotion.title,
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
                initialValue: promotion.description,
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
                initialValue: promotion.instructions,
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
                        validator: (value) =>
                            validateEmptyString(value, texts["empty-value"]!),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        initialValue: promotion.percentage.toString(),
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
                        validator: (value) =>
                            validateEmptyDate(value, texts["empty-value"]!),
                        initialValue: promotion.expiredAt,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: texts["expiration-date-label"]!,
                          hintText: texts["expiration-date-hint"]!,
                          border: const OutlineInputBorder(),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AsyncButtonWidget(
                buttonText: texts["edit-button"]!,
                onPressed: () async {
                  await handleEditPromotion(context, key, texts, promotion);
                },
              ),
              const SizedBox(height: 4),
              AsyncTextButtonWidget(
                  buttonText: texts["delete-button"]!,
                  onPressed: () async {
                    await handleDeletePromotion(context, promotion, texts);
                  }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  //Methods
  String getExpirationDate(DateTime expirationDay) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(expirationDay);
    return formattedDate;
  }

  Future<void> handleEditPromotion(
    BuildContext context,
    GlobalKey<FormBuilderState> key,
    texts,
    Promotion promotion,
  ) async {
    if (!key.currentState!.saveAndValidate()) return;

    Map<String, dynamic> copyOfFields = Map.of(key.currentState!.fields);
    copyOfFields["business_id"] = promotion.businessId;

    bool promotionEdited = await context
        .read<OwnedBusinessDetailsCubit>()
        .editPromotion(copyOfFields, promotion);

    if (!context.mounted) return;

    if (!promotionEdited) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts["promotion-error"]!),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texts["promotion-edited"]!),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> handleDeletePromotion(
      BuildContext context, Promotion promotion, texts) async {
    bool promotionDeleted = await context
        .read<OwnedBusinessDetailsCubit>()
        .deletePromotion(promotion);

    if (!context.mounted) return;

    if (!promotionDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts["promotion-delete-error"]!),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texts["promotion-deleted"]!),
      ),
    );
    Navigator.of(context).pop();
  }
}
