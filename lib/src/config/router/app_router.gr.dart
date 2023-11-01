// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i14;
import 'package:flutter/material.dart' as _i15;
import 'package:heroes_app/src/presentation/pages/auth/auth_view.dart' as _i1;
import 'package:heroes_app/src/presentation/pages/auth/pages/first_time_view.dart'
    as _i6;
import 'package:heroes_app/src/presentation/pages/auth/pages/login_view.dart'
    as _i7;
import 'package:heroes_app/src/presentation/pages/auth/pages/restore_password_view.dart'
    as _i9;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_business.dart'
    as _i11;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_view.dart'
    as _i12;
import 'package:heroes_app/src/presentation/pages/dashboard/dashboard_view.dart'
    as _i2;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/favorites_view.dart'
    as _i5;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/edit_profile_view.dart'
    as _i3;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/profile_view.dart'
    as _i8;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/search_view.dart'
    as _i10;
import 'package:heroes_app/src/presentation/pages/entryPoint/entrypoint_view.dart'
    as _i4;
import 'package:heroes_app/src/presentation/pages/entryPoint/pages/unverified_user_view.dart'
    as _i13;

abstract class $AppRouter extends _i14.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i14.PageFactory> pagesMap = {
    AuthView.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AuthView(),
      );
    },
    DashBoardView.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.DashBoardView(),
      );
    },
    EditProfileView.name: (routeData) {
      final args = routeData.argsAs<EditProfileViewArgs>(
          orElse: () => const EditProfileViewArgs());
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.EditProfileView(key: args.key),
      );
    },
    EntryPointView.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.EntryPointView(),
      );
    },
    FavoritesView.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.FavoritesView(),
      );
    },
    FirstTimeView.name: (routeData) {
      final args = routeData.argsAs<FirstTimeViewArgs>(
          orElse: () => const FirstTimeViewArgs());
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i6.FirstTimeView(key: args.key),
      );
    },
    LoginView.name: (routeData) {
      final args = routeData.argsAs<LoginViewArgs>();
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.LoginView(
          key: args.key,
          onResult: args.onResult,
        ),
      );
    },
    ProfileView.name: (routeData) {
      final args = routeData.argsAs<ProfileViewArgs>(
          orElse: () => const ProfileViewArgs());
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.ProfileView(key: args.key),
      );
    },
    RestorePassword.name: (routeData) {
      final args = routeData.argsAs<RestorePasswordArgs>(
          orElse: () => const RestorePasswordArgs());
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i9.RestorePassword(key: args.key),
      );
    },
    SearchView.name: (routeData) {
      final args = routeData.argsAs<SearchViewArgs>(
          orElse: () => const SearchViewArgs());
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i10.SearchView(key: args.key),
      );
    },
    SignUpBusinessView.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.SignUpBusinessView(),
      );
    },
    SignUpView.name: (routeData) {
      final args = routeData.argsAs<SignUpViewArgs>();
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i12.SignUpView(
          key: args.key,
          onResult: args.onResult,
        ),
      );
    },
    UnverifiedUserView.name: (routeData) {
      final args = routeData.argsAs<UnverifiedUserViewArgs>(
          orElse: () => const UnverifiedUserViewArgs());
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i13.UnverifiedUserView(key: args.key),
      );
    },
  };
}

/// generated route for
/// [_i1.AuthView]
class AuthView extends _i14.PageRouteInfo<void> {
  const AuthView({List<_i14.PageRouteInfo>? children})
      : super(
          AuthView.name,
          initialChildren: children,
        );

  static const String name = 'AuthView';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i2.DashBoardView]
class DashBoardView extends _i14.PageRouteInfo<void> {
  const DashBoardView({List<_i14.PageRouteInfo>? children})
      : super(
          DashBoardView.name,
          initialChildren: children,
        );

  static const String name = 'DashBoardView';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i3.EditProfileView]
class EditProfileView extends _i14.PageRouteInfo<EditProfileViewArgs> {
  EditProfileView({
    _i15.Key? key,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          EditProfileView.name,
          args: EditProfileViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'EditProfileView';

  static const _i14.PageInfo<EditProfileViewArgs> page =
      _i14.PageInfo<EditProfileViewArgs>(name);
}

class EditProfileViewArgs {
  const EditProfileViewArgs({this.key});

  final _i15.Key? key;

  @override
  String toString() {
    return 'EditProfileViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i4.EntryPointView]
class EntryPointView extends _i14.PageRouteInfo<void> {
  const EntryPointView({List<_i14.PageRouteInfo>? children})
      : super(
          EntryPointView.name,
          initialChildren: children,
        );

  static const String name = 'EntryPointView';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i5.FavoritesView]
class FavoritesView extends _i14.PageRouteInfo<void> {
  const FavoritesView({List<_i14.PageRouteInfo>? children})
      : super(
          FavoritesView.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesView';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i6.FirstTimeView]
class FirstTimeView extends _i14.PageRouteInfo<FirstTimeViewArgs> {
  FirstTimeView({
    _i15.Key? key,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          FirstTimeView.name,
          args: FirstTimeViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'FirstTimeView';

  static const _i14.PageInfo<FirstTimeViewArgs> page =
      _i14.PageInfo<FirstTimeViewArgs>(name);
}

class FirstTimeViewArgs {
  const FirstTimeViewArgs({this.key});

  final _i15.Key? key;

  @override
  String toString() {
    return 'FirstTimeViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i7.LoginView]
class LoginView extends _i14.PageRouteInfo<LoginViewArgs> {
  LoginView({
    _i15.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          LoginView.name,
          args: LoginViewArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginView';

  static const _i14.PageInfo<LoginViewArgs> page =
      _i14.PageInfo<LoginViewArgs>(name);
}

class LoginViewArgs {
  const LoginViewArgs({
    this.key,
    required this.onResult,
  });

  final _i15.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'LoginViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i8.ProfileView]
class ProfileView extends _i14.PageRouteInfo<ProfileViewArgs> {
  ProfileView({
    _i15.Key? key,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          ProfileView.name,
          args: ProfileViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ProfileView';

  static const _i14.PageInfo<ProfileViewArgs> page =
      _i14.PageInfo<ProfileViewArgs>(name);
}

class ProfileViewArgs {
  const ProfileViewArgs({this.key});

  final _i15.Key? key;

  @override
  String toString() {
    return 'ProfileViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i9.RestorePassword]
class RestorePassword extends _i14.PageRouteInfo<RestorePasswordArgs> {
  RestorePassword({
    _i15.Key? key,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          RestorePassword.name,
          args: RestorePasswordArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'RestorePassword';

  static const _i14.PageInfo<RestorePasswordArgs> page =
      _i14.PageInfo<RestorePasswordArgs>(name);
}

class RestorePasswordArgs {
  const RestorePasswordArgs({this.key});

  final _i15.Key? key;

  @override
  String toString() {
    return 'RestorePasswordArgs{key: $key}';
  }
}

/// generated route for
/// [_i10.SearchView]
class SearchView extends _i14.PageRouteInfo<SearchViewArgs> {
  SearchView({
    _i15.Key? key,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          SearchView.name,
          args: SearchViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SearchView';

  static const _i14.PageInfo<SearchViewArgs> page =
      _i14.PageInfo<SearchViewArgs>(name);
}

class SearchViewArgs {
  const SearchViewArgs({this.key});

  final _i15.Key? key;

  @override
  String toString() {
    return 'SearchViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i11.SignUpBusinessView]
class SignUpBusinessView extends _i14.PageRouteInfo<void> {
  const SignUpBusinessView({List<_i14.PageRouteInfo>? children})
      : super(
          SignUpBusinessView.name,
          initialChildren: children,
        );

  static const String name = 'SignUpBusinessView';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i12.SignUpView]
class SignUpView extends _i14.PageRouteInfo<SignUpViewArgs> {
  SignUpView({
    _i15.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          SignUpView.name,
          args: SignUpViewArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'SignUpView';

  static const _i14.PageInfo<SignUpViewArgs> page =
      _i14.PageInfo<SignUpViewArgs>(name);
}

class SignUpViewArgs {
  const SignUpViewArgs({
    this.key,
    required this.onResult,
  });

  final _i15.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'SignUpViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i13.UnverifiedUserView]
class UnverifiedUserView extends _i14.PageRouteInfo<UnverifiedUserViewArgs> {
  UnverifiedUserView({
    _i15.Key? key,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          UnverifiedUserView.name,
          args: UnverifiedUserViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'UnverifiedUserView';

  static const _i14.PageInfo<UnverifiedUserViewArgs> page =
      _i14.PageInfo<UnverifiedUserViewArgs>(name);
}

class UnverifiedUserViewArgs {
  const UnverifiedUserViewArgs({this.key});

  final _i15.Key? key;

  @override
  String toString() {
    return 'UnverifiedUserViewArgs{key: $key}';
  }
}
