import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';

class HorizontalCard extends StatelessWidget {
  const HorizontalCard({
    super.key,
    required this.image,
    required this.title,
    required this.id,
    required this.callback,
    this.isOnGrid = false,
    this.category,
    this.businessType = 'physical',
  });

  final String image;
  final String title;
  final String id;
  final Function callback;
  final bool isOnGrid;
  final BusinessCategory? category;
  final String businessType; // "physical" | "online" | "hybrid"

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      width: isOnGrid ? 250 : double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => callback(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  image.isNotEmpty
                      ? Image.network(
                        image,
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                        height: !isOnGrid ? 180 : 130,
                      )
                      : Image.asset(
                        "assets/images/file-not-found.png",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: !isOnGrid ? 180 : 130,
                      ),
                  // Business type badge
                  if (businessType == 'online' || businessType == 'hybrid')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              businessType == 'online'
                                  ? Icons.language
                                  : Icons.store_mall_directory,
                              size: 14,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              businessType == 'online' ? 'En línea' : 'Híbrido',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              content(theme, category),
            ],
          ),
        ),
      ),
    );
  }

  Widget content(ThemeData theme, BusinessCategory? category) {
    final hasCategory = category != null;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: hasCategory || isOnGrid ? 12 : 24,
      ),
      child: Row(
        children: [
          if (category != null) const SizedBox(width: 8),
          if (category != null)
            SvgPicture.network(category.imageUrl, width: 24, height: 24),
          if (category != null) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: theme.textTheme.labelLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (hasCategory)
                  Text(
                    category.name,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: theme.textTheme.labelLarge!.fontSize,
                      fontWeight: theme.textTheme.labelLarge!.fontWeight,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
