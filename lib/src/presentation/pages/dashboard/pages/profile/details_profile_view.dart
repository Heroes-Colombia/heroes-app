import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/presentation/cubits/profile/profile_cubit.dart';
import 'package:ionicons/ionicons.dart';

final updateUserForm = GlobalKey<FormBuilderState>();

@RoutePage()
class DetailsProfileView extends StatelessWidget {
  DetailsProfileView({super.key});
  final locator = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var texts =
        locator.get<AppConstants>().dashBoardTexts['detailsProfileView']!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<ProfileCubit>().restoreProfileState();
          Navigator.of(context).pop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            forceMaterialTransparency: true,
          ),
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              switch (state.runtimeType) {
                case const (ProfileInitial):
                  // Always get fresh profile info when in initial state
                  context.read<ProfileCubit>().getInitialProfileInfo();
                  return loadingView(context, theme, texts);
                case const (ProfileLoaded):
                  // Verify we're showing data for the current user by comparing UIDs
                  final currentUserId = locator.get<AuthService>().getUserId();
                  if (state.user?.uid != currentUserId) {
                    // If UIDs don't match, refresh the profile data
                    context.read<ProfileCubit>().getInitialProfileInfo();
                    return loadingView(context, theme, texts);
                  }
                  return successView(context, state.user!, texts, theme);
                default:
                  return errorView(context, theme, texts);
              }
            },
          ),
        ),
      ),
    );
  }

  //This method is used to show a success view when the user info is loaded
  successView(BuildContext context, User user, texts, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.38,
          color: theme.colorScheme.primary.withOpacity(0.8),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 49,
                bottom: 20,
                top: 0,
                child: SvgPicture.asset(
                  'assets/images/app_icon.svg',
                  height: 100,
                  width: 200,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Positioned(
                top: 140,
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${user.firstName} ${user.firstLastName}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: theme.textTheme.bodyLarge!.fontSize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.rank.contains("_")
                          ? user.rank.split("_").last
                          : user.rank.split(" ").last,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w400,
                        fontSize: theme.textTheme.bodyMedium!.fontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: theme.colorScheme.primary.withOpacity(0.8),
          height: MediaQuery.of(context).size.height * 0.62,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed:
                        () =>
                            AutoRouter.of(context).navigate(EditProfileView()),
                    icon: const Icon(Ionicons.pencil_outline),
                    label: Text(texts['edit-profile']!),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${user.firstName} ${user.firstLastName} ${user.secondName} ${user.secondLastName}',
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: theme.textTheme.labelMedium!.fontSize,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        texts['fullname-label']!,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.8,
                          ),
                          fontWeight: FontWeight.w600,
                          fontSize: theme.textTheme.labelMedium!.fontSize,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Divider(
                    thickness: 0.5,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          user.email,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: theme.textTheme.labelMedium!.fontSize,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        texts['email-label']!,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.8,
                          ),
                          fontWeight: FontWeight.w600,
                          fontSize: theme.textTheme.labelMedium!.fontSize,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Divider(
                    thickness: 0.5,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  loadingRankPermission(context, theme, texts, user),
                  const SizedBox(height: 6),
                  Divider(
                    thickness: 0.5,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  if (user.license != null && user.license!.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.license!,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: theme.textTheme.labelMedium!.fontSize,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          texts['license-label']!,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: theme.textTheme.labelMedium!.fontSize,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Divider(
                      thickness: 0.5,
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (user.identificationCard != null &&
                      user.identificationCard!.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            user.identificationCard!,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: theme.textTheme.labelMedium!.fontSize,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          texts['identification-label']!,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: theme.textTheme.labelMedium!.fontSize,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Divider(
                      thickness: 0.5,
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  //This method is used to show the user's permission and rank
  //It will show the rank if the user is a regular user and the position if the user is an admin
  loadingRankPermission(
    BuildContext context,
    ThemeData theme,
    texts,
    User user,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            user.permission == UserPermissions.user
                ? user.rank.split("_").last
                : user.permission == UserPermissions.admin
                ? user.permission.name
                : user.rank.trim().split("_").last,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: theme.textTheme.labelMedium!.fontSize,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          user.permission == UserPermissions.user
              ? (texts['rank-label']!)
              : (texts['position-label']!),
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            fontSize: theme.textTheme.labelMedium!.fontSize,
          ),
        ),
      ],
    );
  }

  //This method is used to show a loading view when the user info is loading
  loadingView(BuildContext context, ThemeData theme, texts) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.38,
          color: theme.colorScheme.primary.withOpacity(0.8),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 49,
                bottom: 20,
                top: 0,
                child: SvgPicture.asset(
                  'assets/images/app_icon.svg',
                  height: 100,
                  width: 200,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: theme.colorScheme.primary.withOpacity(0.8),
          height: MediaQuery.of(context).size.height * 0.62,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }

  //This method is used to show an initial view when the user info started loading
  initialView(BuildContext context, ThemeData theme, texts) {
    return CustomScrollView(
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
      ],
    );
  }

  //This method is used to show an error view when the user info is not loaded
  errorView(BuildContext context, ThemeData theme, texts) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(
            texts['error-title']!,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              fontSize: theme.textTheme.headlineSmall!.fontSize,
            ),
          ),
        ),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
