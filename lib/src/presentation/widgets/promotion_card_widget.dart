import 'package:flutter/material.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
    required this.promotion,
    required this.callback,
  });

  final Promotion promotion;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: callback,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with discount badge overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: promotion.featuredImage.isNotEmpty
                        ? Image.network(
                            promotion.featuredImage,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 140,
                                color: theme.colorScheme.surfaceVariant,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 140,
                                color: theme.colorScheme.surfaceVariant,
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                ),
                              );
                            },
                          )
                        : Container(
                            height: 140,
                            color: theme.colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                  ),
                  // Discount badge
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
                ],
              ),
              // Promotion details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      promotion.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: theme.textTheme.titleMedium!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Urgency badge
                    if (promotion.shouldShowUrgencyBadge)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(theme, promotion.urgencyLevel),
                          borderRadius: BorderRadius.circular(12),
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
                  ],
                ),
              ),
            ],
          ),
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
