// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:flutter/material.dart' as _i11;
import 'package:heroes_app/src/presentation/pages/auth/auth_view.dart' as _i1;
import 'package:heroes_app/src/presentation/pages/auth/pages/first_time_view.dart'
    as _i4;
import 'package:heroes_app/src/presentation/pages/auth/pages/login_view.dart'
    as _i5;
import 'package:heroes_app/src/presentation/pages/auth/pages/restore_password_view.dart'
    as _i7;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_view.dart'
    as _i9;
import 'package:heroes_app/src/presentation/pages/dashboard/dashboard_view.dart'
    as _i2;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/favorites_view.dart'
    as _i3;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile_view.dart'
    as _i6;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search_view.dart'
    as _i8;

abstract class $AppRouter extends _i10.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i10.PageFactory> pagesMap = {
    AuthView.name: (routeData) {
      return _i10.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AuthView(),
      );
    },
    DashBoardView.name: (routeData) {
      return _i10.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.DashBoardView(),
      );
    },
    FavoritesView.name: (routeData) {
      return _i10.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.FavoritesView(),
      );
    },
    FirstTimeView.name: (routeData) {
      final args = routeData.argsAs<FirstTimeViewArgs>(
          orElse: () => const FirstTimeViewArgs());
      return _i10.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.FirstTimeView(key: args.key),
      );
    },
    LoginView.name: (routeData) {
      final args = routeData.argsAs<LoginViewArgs>();
      return _i10.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i5.LoginView(
          key: args.key,
          onResult: args.onResult,
        ),
      );
    },
    ProfileView.name: (routeData) {
      return _i10.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.ProfileView(),
      );
    },
    RestorePassword.name: (routeData) {
      final args = routeData.argsAs<RestorePasswordArgs>(
          orElse: () => const RestorePasswordArgs());
      return _i10.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.RestorePassword(key: args.key),
      );
    },
    SearchView.name: (routeData) {
      return _i10.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.SearchView(),
      );
    },
    SignUpView.name: (routeData) {
      final args = routeData.argsAs<SignUpViewArgs>();
      return _i10.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i9.SignUpView(
          key: args.key,
          onResult: args.onResult,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.AuthView]
class AuthView extends _i10.PageRouteInfo<void> {
  const AuthView({List<_i10.PageRouteInfo>? children})
      : super(
          AuthView.name,
          initialChildren: children,
        );

  static const String name = 'AuthView';

  static const _i10.PageInfo<void> page = _i10.PageInfo<void>(name);
}

/// generated route for
/// [_i2.DashBoardView]
class DashBoardView extends _i10.PageRouteInfo<void> {
  const DashBoardView({List<_i10.PageRouteInfo>? children})
      : super(
          DashBoardView.name,
          initialChildren: children,
        );

  static const String name = 'DashBoardView';

  static const _i10.PageInfo<void> page = _i10.PageInfo<void>(name);
}

/// generated route for
/// [_i3.FavoritesView]
class FavoritesView extends _i10.PageRouteInfo<void> {
  const FavoritesView({List<_i10.PageRouteInfo>? children})
      : super(
          FavoritesView.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesView';

  static const _i10.PageInfo<void> page = _i10.PageInfo<void>(name);
}

/// generated route for
/// [_i4.FirstTimeView]
class FirstTimeView extends _i10.PageRouteInfo<FirstTimeViewArgs> {
  FirstTimeView({
    _i11.Key? key,
    List<_i10.PageRouteInfo>? children,
  }) : super(
          FirstTimeView.name,
          args: FirstTimeViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'FirstTimeView';

  static const _i10.PageInfo<FirstTimeViewArgs> page =
      _i10.PageInfo<FirstTimeViewArgs>(name);
}

class FirstTimeViewArgs {
  const FirstTimeViewArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'FirstTimeViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i5.LoginView]
class LoginView extends _i10.PageRouteInfo<LoginViewArgs> {
  LoginView({
    _i11.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i10.PageRouteInfo>? children,
  }) : super(
          LoginView.name,
          args: LoginViewArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginView';

  static const _i10.PageInfo<LoginViewArgs> page =
      _i10.PageInfo<LoginViewArgs>(name);
}

class LoginViewArgs {
  const LoginViewArgs({
    this.key,
    required this.onResult,
  });

  final _i11.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'LoginViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i6.ProfileView]
class ProfileView extends _i10.PageRouteInfo<void> {
  const ProfileView({List<_i10.PageRouteInfo>? children})
      : super(
          ProfileView.name,
          initialChildren: children,
        );

  static const String name = 'ProfileView';

  static const _i10.PageInfo<void> page = _i10.PageInfo<void>(name);
}

/// generated route for
/// [_i7.RestorePassword]
class RestorePassword extends _i10.PageRouteInfo<RestorePasswordArgs> {
  RestorePassword({
    _i11.Key? key,
    List<_i10.PageRouteInfo>? children,
  }) : super(
          RestorePassword.name,
          args: RestorePasswordArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'RestorePassword';

  static const _i10.PageInfo<RestorePasswordArgs> page =
      _i10.PageInfo<RestorePasswordArgs>(name);
}

class RestorePasswordArgs {
  const RestorePasswordArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'RestorePasswordArgs{key: $key}';
  }
}

/// generated route for
/// [_i8.SearchView]
class SearchView extends _i10.PageRouteInfo<void> {
  const SearchView({List<_i10.PageRouteInfo>? children})
      : super(
          SearchView.name,
          initialChildren: children,
        );

  static const String name = 'SearchView';

  static const _i10.PageInfo<void> page = _i10.PageInfo<void>(name);
}

/// generated route for
/// [_i9.SignUpView]
class SignUpView extends _i10.PageRouteInfo<SignUpViewArgs> {
  SignUpView({
    _i11.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i10.PageRouteInfo>? children,
  }) : super(
          SignUpView.name,
          args: SignUpViewArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'SignUpView';

  static const _i10.PageInfo<SignUpViewArgs> page =
      _i10.PageInfo<SignUpViewArgs>(name);
}

class SignUpViewArgs {
  const SignUpViewArgs({
    this.key,
    required this.onResult,
  });

  final _i11.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'SignUpViewArgs{key: $key, onResult: $onResult}';
  }
}
