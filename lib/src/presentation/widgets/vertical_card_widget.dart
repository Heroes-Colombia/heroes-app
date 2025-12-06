import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';

class VerticalCard extends StatelessWidget {
  const VerticalCard({
    super.key,
    required this.image,
    required this.title,
    required this.id,
    this.description,
    required this.callback,
    required this.category,
    this.businessType = 'physical',
    this.urgentPromotion,
    this.formattedDistance,
    this.isFeatured = false,
    this.physicalLocationsCount,
  });

  final String id;
  final String image;
  final String title;
  final String? description;
  final Function callback;
  final BusinessCategory? category;
  final String businessType; // "physical" | "online" | "hybrid"
  final Promotion? urgentPromotion; // Urgent promotion for badge
  final String? formattedDistance; // Distance from user (e.g., "1.2 km")
  final bool isFeatured; // Enterprise plan businesses get premium badge
  final int? physicalLocationsCount; // Count of physical locations

  // Helper to normalize business name to title case
  String _normalizeBusinessName(String name) {
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () => callback(),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            content(theme, category),
            const SizedBox(width: 12),
            // Use AspectRatio for consistent image display (square)
            SizedBox(
              height: 80,
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        // Performance optimizations
                        cacheWidth: 160, // 2x resolution for sharp display
                        cacheHeight: 160,
                        filterQuality: FilterQuality.medium,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/images/file-not-found.png",
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        "assets/images/file-not-found.png",
                        fit: BoxFit.cover,
                      ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget content(ThemeData theme, BusinessCategory? category) {
    return Expanded(
      child: Row(
        children: [
          if (category != null)
            SvgPicture.network(
              category.imageUrl,
              width: 24,
              height: 24,
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _normalizeBusinessName(title),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: theme.textTheme.labelLarge!.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Business type badge
                    if (businessType == 'online' || businessType == 'hybrid')
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          businessType == 'online'
                              ? Icons.language
                              : Icons.store_mall_directory,
                          size: 12,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    // Premium badge for Enterprise businesses
                    if (isFeatured)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade600,
                              Colors.orange.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              size: 10,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                // Category and distance row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category?.name ?? description ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.8),
                          fontSize: theme.textTheme.labelMedium!.fontSize,
                          fontWeight: theme.textTheme.bodySmall!.fontWeight,
                        ),
                      ),
                    ),
                    // Distance indicator (only for physical businesses)
                    if (formattedDistance != null && businessType != 'online')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Sede Principal • $formattedDistance',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: theme.textTheme.labelSmall!.fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Show location count badge if >1 physical location
                          if (physicalLocationsCount != null && physicalLocationsCount! > 1) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '+${physicalLocationsCount! - 1}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
                // Urgency badge for promotions
                if (urgentPromotion != null &&
                    urgentPromotion!.shouldShowUrgencyBadge) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getUrgencyColor(theme, urgentPromotion!.urgencyLevel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          urgentPromotion!.urgencyText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(ThemeData theme, String urgencyLevel) {
    switch (urgencyLevel) {
      case 'critical':
        return theme.colorScheme.error;
      case 'urgent':
        return Colors.orange;
      case 'normal':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.primary;
    }
  }
}
