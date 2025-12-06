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
      width: isOnGrid ? 250 : double.infinity,
      margin: isOnGrid ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => callback(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with 4:3 aspect ratio
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    image.isNotEmpty
                        ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          // Performance optimizations
                          cacheWidth:
                              560, // 2x resolution for sharp display (280 * 2)
                          cacheHeight:
                              420, // 2x resolution for 4:3 ratio (210 * 2)
                          filterQuality: FilterQuality.medium,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
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
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                            );
                          },
                        )
                        : Container(
                          width: double.infinity,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
              ),
            ),
            // Business details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Business name
                  Text(
                    _normalizeBusinessName(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: theme.textTheme.titleMedium!.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Category (icon + name)
                  if (category != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.network(
                          category!.imageUrl,
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            category!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontSize: theme.textTheme.labelMedium!.fontSize,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
