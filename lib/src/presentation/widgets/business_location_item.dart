import 'package:flutter/material.dart';
import 'package:heroes_app/src/domain/models/business_location.dart';
import 'package:ionicons/ionicons.dart';

/// Widget to display a single business location with navigation capability.
/// Shows primary badge, type icon, distance, and navigation button.
class BusinessLocationItem extends StatelessWidget {
  const BusinessLocationItem({
    super.key,
    required this.location,
    required this.onNavigate,
    this.onCall,
    this.onWhatsApp,
    this.website,
  });

  final BusinessLocation location;
  final VoidCallback onNavigate;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;
  final String? website;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isPhysical = location.isPhysical;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border:
            location.isPrimary
                ? Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  width: 2,
                )
                : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isPhysical) ...[
            // Icon (physical/online)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.language,
                color: theme.colorScheme.onSecondaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Location details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Primary badge
                Row(
                  children: [
                    if (location.isPrimary) ...[
                      Icon(
                        Icons.star,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        location.name,
                        style: TextStyle(
                          fontSize: theme.textTheme.titleSmall!.fontSize,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Address (physical only)
                if (isPhysical && location.address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    location.address!,
                    style: TextStyle(
                      fontSize: theme.textTheme.bodySmall!.fontSize,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Distance (physical only)
                if (isPhysical && location.formattedDistance != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location.formattedDistance!,
                        style: TextStyle(
                          fontSize: theme.textTheme.labelSmall!.fontSize,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                // Online indicator
                if (!isPhysical) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Conoce más en la pagina web',
                    style: TextStyle(
                      fontSize: theme.textTheme.bodySmall!.fontSize,
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((!isPhysical && website != "") || isPhysical) ...[
                // Navigation button
                IconButton(
                  onPressed: onNavigate,
                  icon: Icon(
                    isPhysical ? Icons.directions : Icons.open_in_new,
                    color: theme.colorScheme.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  tooltip: isPhysical ? 'Cómo llegar' : 'Abrir sitio web',
                ),
              ],
              // Three-dot menu for call/WhatsApp (only if callbacks provided)
              if (isPhysical && (onCall != null || onWhatsApp != null)) ...[
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'call' && onCall != null) {
                      onCall!();
                    } else if (value == 'whatsapp' && onWhatsApp != null) {
                      onWhatsApp!();
                    }
                  },
                  icon: Icon(Icons.more_vert, color: theme.colorScheme.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  itemBuilder:
                      (context) => [
                        if (onCall != null)
                          const PopupMenuItem(
                            value: 'call',
                            child: Row(
                              children: [
                                Icon(Ionicons.call_outline, size: 18),
                                SizedBox(width: 12),
                                Text('Llamar'),
                              ],
                            ),
                          ),
                        if (onWhatsApp != null)
                          const PopupMenuItem(
                            value: 'whatsapp',
                            child: Row(
                              children: [
                                Icon(Ionicons.logo_whatsapp, size: 18),
                                SizedBox(width: 12),
                                Text('WhatsApp'),
                              ],
                            ),
                          ),
                      ],
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
