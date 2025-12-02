import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';

/// Category filter carousel for map view
/// Displays horizontal scrollable chips to filter businesses by category
class MapCategoryFilter extends StatelessWidget {
  final List<BusinessCategory> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const MapCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          itemCount: categories.length + 1, // +1 for "All" chip
          itemBuilder: (context, index) {
            if (index == 0) {
              // "All" chip to reset filter
              return _buildCategoryChip(
                context,
                label: 'All',
                icon: Icons.apps,
                isSelected: selectedCategoryId == null,
                onTap: () => onCategorySelected(null),
              );
            }

            final category = categories[index - 1];
            return _buildCategoryChip(
              context,
              label: category.name,
              imageUrl: category.imageUrl,
              isSelected: selectedCategoryId == category.id,
              onTap: () => onCategorySelected(category.id),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    String? imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show icon or image
            if (icon != null)
              Icon(icon, size: 18)
            else if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildCategoryImage(imageUrl),
              )
            else
              const Icon(Icons.category, size: 18),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primaryContainer,
        backgroundColor: theme.colorScheme.surface,
        checkmarkColor: theme.colorScheme.onPrimaryContainer,
        side: BorderSide(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
          width: 1,
        ),
      ),
    );
  }

  /// Build category image widget, handling both SVG and regular images
  Widget _buildCategoryImage(String imageUrl) {
    final isSvg = imageUrl.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.network(
        imageUrl,
        width: 18,
        height: 18,
        fit: BoxFit.cover,
        placeholderBuilder:
            (context) => const SizedBox(
              width: 18,
              height: 18,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
      );
    } else {
      return Image.network(
        imageUrl,
        width: 18,
        height: 18,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) =>
                const Icon(Icons.category, size: 18),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 18,
            height: 18,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    }
  }
}
