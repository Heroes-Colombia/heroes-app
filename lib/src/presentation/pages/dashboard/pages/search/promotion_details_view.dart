import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/presentation/cubits/promotion/promotion_details_cubit.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

@RoutePage()
class PromotionDetailsView extends StatefulWidget {
  final Promotion? promotion;
  final String? promotionId;
  const PromotionDetailsView(
      {super.key, required this.promotion, required this.promotionId});

  @override
  State<PromotionDetailsView> createState() => _PromotionDetailsViewState();
}

class _PromotionDetailsViewState extends State<PromotionDetailsView> {
  @override
  void initState() {
    super.initState();
    if (widget.promotion == null && widget.promotionId != null) {
      context
          .read<PromotionDetailsCubit>()
          .getPromotionDetails(widget.promotionId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts =
        locator.get<AppConstants>().dashBoardTexts['promotionDetailsView']!;

    return Scaffold(
      body: widget.promotion != null
          ? promotionBodyWidget(texts, theme, widget.promotion!)
          : BlocBuilder<PromotionDetailsCubit, PromotionDetailsState>(
              builder: (context, state) {
                switch (state.status) {
                  case BusinessViewCubitStatus.initial:
                    return const Center(child: CircularProgressIndicator());
                  case BusinessViewCubitStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case BusinessViewCubitStatus.success:
                    return promotionBodyWidget(texts, theme, state.promotion!);
                  case BusinessViewCubitStatus.error:
                    return const Center(child: Text('Error'));

                  default:
                    return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }

  CustomScrollView promotionBodyWidget(
      Map<String, String> texts, ThemeData theme, Promotion promotion) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
            title: Text(
          texts['title']!,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
            fontSize: theme.textTheme.headlineSmall!.fontSize,
          ),
        )),
        SliverToBoxAdapter(
          child: Container(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 12),
            child: SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
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
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 24),
            child: Text(
              promotion.title,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
                fontSize: theme.textTheme.bodyLarge!.fontSize,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        divider(theme),
        sectionTitle(texts['description-title']!, theme),
        sectionBody(theme, promotion.description),
        sectionTitle(texts['instructions-title']!, theme),
        sectionBody(theme, promotion.instructions),
        divider(theme),
        sectionDouble(
            theme, texts['discount-title']!, "${promotion.percentage}%"),
        sectionDouble(theme, texts['expiration-title']!,
            getExpirationDate(promotion.expiredAt)),
        const SliverToBoxAdapter(child: SizedBox(height: 12))
      ],
    );
  }

  SliverToBoxAdapter sectionTitle(String text, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: theme.textTheme.labelLarge!.fontSize,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter sectionBody(ThemeData theme, text) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Text(
          text,
          style: TextStyle(
            fontSize: theme.textTheme.labelLarge!.fontSize,
            fontWeight: theme.textTheme.bodySmall!.fontWeight,
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter sectionDouble(ThemeData theme, title, text) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: theme.textTheme.labelLarge!.fontSize,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: theme.textTheme.labelLarge!.fontSize,
                fontWeight: theme.textTheme.bodySmall!.fontWeight,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter divider(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
        child: Divider(
          height: 1,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  String getExpirationDate(DateTime expirationDay) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(expirationDay);
    return formattedDate;
  }
}
