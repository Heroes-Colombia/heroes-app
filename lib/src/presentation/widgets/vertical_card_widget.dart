import 'package:flutter/material.dart';

class VerticalCard extends StatelessWidget {
  const VerticalCard({
    super.key,
    required this.image,
    required this.title,
    required this.id,
    this.description,
  });

  final String id;
  final String image;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          ),
          padding: const EdgeInsets.only(left: 12),
          height: 80,
          child: Row(children: [
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
                      fontWeight: theme.textTheme.labelLarge!.fontWeight,
                    ),
                  ),
                  description != null
                      ? Text(
                          description!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: theme.textTheme.labelSmall!.fontSize,
                            fontWeight: theme.textTheme.labelSmall!.fontWeight,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                child: Image.network(
                  image.isEmpty ? "assets/images/file-not-found.png" : image,
                  fit: BoxFit.cover,
                )),
          ]),
        ),
      ),
    );
  }
}
