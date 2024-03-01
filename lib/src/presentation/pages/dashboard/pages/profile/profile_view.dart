import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/repositories/cloud_message_service.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/profile/profile_cubit.dart';
import 'package:ionicons/ionicons.dart';

@RoutePage()
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final locator = GetIt.instance;
  var favoriteTopic = true;
  var discoverTopic = true;

  @override
  void initState() {
    super.initState();

    initTopics();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var texts = locator.get<AppConstants>().dashBoardTexts['profileView']!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              texts['title']!,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
                fontSize: theme.textTheme.headlineSmall!.fontSize,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListBody(children: [
                const SizedBox(height: 16),
                Text(
                  texts['account']!,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: theme.textTheme.labelLarge!.fontSize,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: SvgPicture.asset(
                    'assets/icon/editProfile.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: Text(texts['edit-profile']!),
                  onTap: () => context.router.push(DetailsProfileView()),
                ),
                ListTile(
                    leading: Icon(
                      Ionicons.log_out_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(texts['logout']!),
                    onTap: () => doLogOut(context, texts)),
                const SizedBox(height: 16),
                Text(
                  texts['settings']!,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: theme.textTheme.labelLarge!.fontSize,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(Ionicons.moon_outline,
                      color: theme.colorScheme.primary),
                  title: Text(texts['dark-mode']!),
                  trailing: Switch(
                    value: AdaptiveTheme.of(context).mode ==
                        AdaptiveThemeMode.dark,
                    onChanged: (_) => changeThemeMode(context),
                  ),
                ),
                notificationSettingsWidget(texts, theme),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  //Widgets
  BlocBuilder<AuthCubit, AuthState> notificationSettingsWidget(
    Map<String, String> texts,
    ThemeData theme,
  ) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      if (state.authStatus != AuthStatus.businessLoggedIn) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              texts['notifications']!,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: theme.textTheme.labelLarge!.fontSize,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icon/notifications_outline.svg',
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              title: Text(texts['favorites-topic']!),
              trailing: Switch(
                value: favoriteTopic,
                onChanged: (value) {
                  handleSetNotificationPreference(
                    locator.get<AppConstants>().favoriteTopic,
                    value,
                  );

                  setState(() {
                    favoriteTopic = value;
                  });
                },
              ),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icon/notifications_outline.svg',
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              title: Text(texts['discover-topic']!),
              trailing: Switch(
                value: discoverTopic,
                onChanged: (value) {
                  handleSetNotificationPreference(
                    locator.get<AppConstants>().discoverTopic,
                    value,
                  );

                  setState(() {
                    discoverTopic = value;
                  });
                },
              ),
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  //Methods

  //This method is used to log out the user
  void doLogOut(BuildContext context, texts) async {
    //First we log out the user
    final userIsLoggedIn = await context.read<AuthCubit>().logOut();
    if (userIsLoggedIn) {
      if (!context.mounted) return;
      //If the user is logged out we navigate to the auth view
      context.router.replaceAll([const AuthView()]);
    } else {
      if (!context.mounted) return;
      //If the user is not logged out we show a snackbar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts['logout-error-message']!),
        ),
      );
    }
  }

//This method is used to change the theme mode
  void changeThemeMode(BuildContext context) {
    //First we get the current theme mode
    final themeMode = AdaptiveTheme.of(context).mode;
    //Then we change the theme mode
    if (themeMode == AdaptiveThemeMode.dark) {
      AdaptiveTheme.of(context).setLight();
    } else {
      AdaptiveTheme.of(context).setDark();
    }
  }

  //This method is used to get the notification
  void initTopics() async {
    //We get the user notification topics preferences
    final favoriteTopicName = locator.get<AppConstants>().favoriteTopic;
    final discoverTopicName = locator.get<AppConstants>().discoverTopic;

    final favoriteTopicNewValue = await context
        .read<ProfileCubit>()
        .getNotificationPreferencesForTopic(favoriteTopicName);
    if (!context.mounted) return;

    final discoverTopicNewValue = await context
        .read<ProfileCubit>()
        .getNotificationPreferencesForTopic(discoverTopicName);

    setState(() {
      favoriteTopic = favoriteTopicNewValue;
      discoverTopic = discoverTopicNewValue;
    });
  }

  void handleSetNotificationPreference(String topic, bool newValue) async {
    await context
        .read<ProfileCubit>()
        .setNotificationPreferencesForTopic(topic);

    if (!context.mounted) return;

    newValue
        ? locator.get<CloudMessageService>().subscribeToTopic(topic)
        : locator.get<CloudMessageService>().unsubscribeFromTopic(topic);
  }
}
