import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class UnverifiedUserView extends StatelessWidget {
  UnverifiedUserView({Key? key}) : super(key: key);
  final locator = GetIt.instance;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var texts =
        locator.get<AppConstants>().entryPointTexts['unverifiedUserView']!;
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Center(
            child: Text(
              texts['title']!,
              textAlign: TextAlign.center,
            ),
          ),
          pinned: true,
        ),
        SliverFillRemaining(
            child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Ionicons.people_circle_outline,
                size: 100,
                color: theme.colorScheme.onBackground,
              ),
              const SizedBox(height: 12),
              Text(
                texts['content']!,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ))
      ],
    ));
  }
}
