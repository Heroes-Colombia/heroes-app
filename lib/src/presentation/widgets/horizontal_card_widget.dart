import 'package:flutter/material.dart';

class HorizontalCard extends StatelessWidget {
  const HorizontalCard({
    super.key,
    required this.image,
    required this.title,
    required this.id,
    required this.callback,
    required this.heroName,
    this.isOnGrid = false,
  });

  final String image;
  final String title;
  final String id;
  final Function callback;
  final String heroName;
  final bool isOnGrid;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      width: !isOnGrid ? 180 : double.infinity,
      height: 174,
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
              Hero(
                tag: heroName,
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 130,
                      )
                    : Image.asset(
                        "assets/images/file-not-found.png",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 130,
                      ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: theme.textTheme.labelLarge!.fontSize,
                          fontWeight: theme.textTheme.labelLarge!.fontWeight,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
