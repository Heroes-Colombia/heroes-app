import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

@RoutePage()
class PromotionDetailsView extends StatelessWidget {
  final Promotion promotion;
  const PromotionDetailsView({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var texts =
        locator.get<AppConstants>().dashBoardTexts['promotionDetailsView']!;

    return Scaffold(
      body: CustomScrollView(
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
          sectionTitle(texts['description-title']!, theme),
          sectionBody(theme, promotion.description),
          sectionTitle(texts['instructions-title']!, theme),
          sectionBody(theme, promotion.instructions),
          sectionTitle(texts['expiration-title']!, theme),
          sectionBody(theme, getExpirationDate(promotion.expiredAt))
        ],
      ),
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
            fontWeight: theme.textTheme.labelLarge!.fontWeight,
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

  String getExpirationDate(DateTime expirationDay) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(expirationDay);
    return formattedDate;
  }
}
