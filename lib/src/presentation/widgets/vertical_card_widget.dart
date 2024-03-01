import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';

class VerticalCard extends StatelessWidget {
  const VerticalCard(
      {super.key,
      required this.image,
      required this.title,
      required this.id,
      this.description,
      required this.callback,
      required this.category});

  final String id;
  final String image;
  final String title;
  final String? description;
  final Function callback;
  final BusinessCategory? category;

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
          padding: const EdgeInsets.only(left: 12),
          height: 80,
          child: Row(children: [
            content(theme, category),
            const SizedBox(width: 12),
            SizedBox(
              height: 80,
              width: 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
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
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: theme.textTheme.labelLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                category != null
                    ? Text(
                        category.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.8),
                          fontSize: theme.textTheme.labelMedium!.fontSize,
                          fontWeight: theme.textTheme.bodySmall!.fontWeight,
                        ),
                      )
                    : Text(
                        description ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.8),
                          fontSize: theme.textTheme.labelMedium!.fontSize,
                          fontWeight: theme.textTheme.bodySmall!.fontWeight,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
