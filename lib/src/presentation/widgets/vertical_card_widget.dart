import 'package:flutter/material.dart';

class VerticalCard extends StatelessWidget {
  const VerticalCard(
      {super.key,
      required this.image,
      required this.title,
      required this.id,
      this.description,
      required this.callback,
      required this.heroName});

  final String id;
  final String image;
  final String title;
  final String? description;
  final Function callback;
  final String heroName;

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
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.8),
                            fontSize: theme.textTheme.labelMedium!.fontSize,
                            fontWeight: theme.textTheme.bodySmall!.fontWeight,
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
              child: Hero(
                tag: heroName,
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
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
}
