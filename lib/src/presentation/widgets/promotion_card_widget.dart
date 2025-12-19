import 'package:flutter/material.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
    required this.promotion,
    required this.callback,
    this.businessName, // Optional override (defaults to promotion.businessName)
    this.categoryName,
    this.isOnGrid = false, // Set to true when used in a grid layout
  });

  final Promotion promotion;
  final VoidCallback callback;
  final String?
  businessName; // Optional business name override (uses promotion.businessName if null)
  final String? categoryName; // Optional category badge
  final bool isOnGrid; // Whether the card is displayed in a grid

  // Helper to get the business name (prioritizes parameter over model field)
  String? get _businessName => businessName ?? promotion.businessName;

  // Helper to normalize business name to title case
  String _normalizeBusinessName(String name) {
    return name
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: isOnGrid ? null : 280,
      margin: isOnGrid ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: callback,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with discount badge overlay
            Stack(
              children: [
                // Use AspectRatio to maintain consistent proportions
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        promotion.featuredImage.isNotEmpty
                            ? Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Image.network(
                                promotion.featuredImage,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                // Performance optimizations
                                cacheWidth:
                                    480, // 2x resolution for sharp display (240 * 2)
                                cacheHeight:
                                    360, // 2x resolution for 4:3 ratio (180 * 2)
                                filterQuality: FilterQuality.medium,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: double.infinity,
                                    color:
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    color:
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                  );
                                },
                              ),
                            )
                            : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primaryContainer,
                                    theme.colorScheme.secondaryContainer,
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    size: 40,
                                    color: theme.colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${promotion.percentage}% OFF',
                                    style: TextStyle(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Promoción Especial',
                                    style: TextStyle(
                                      color: theme
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
                // Category badge (top-left)
                if (categoryName != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        categoryName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                // Discount badge (top-right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${promotion.percentage}% OFF',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Urgency badge (bottom-left)
                if (promotion.shouldShowUrgencyBadge)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getUrgencyColor(theme, promotion.urgencyLevel),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            promotion.urgencyText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Promotion details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Business name (if available) - shown first
                  if (_businessName != null) ...[
                    Text(
                      _normalizeBusinessName(_businessName!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: theme.textTheme.titleMedium!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  // Title (secondary to business name)
                  Text(
                    promotion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: _businessName != null ? 0.7 : 1.0,
                      ),
                      fontSize:
                          _businessName != null
                              ? theme.textTheme.labelMedium!.fontSize
                              : theme.textTheme.titleMedium!.fontSize,
                      fontWeight:
                          _businessName != null
                              ? FontWeight.normal
                              : FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
