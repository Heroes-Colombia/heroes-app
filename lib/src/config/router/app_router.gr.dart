// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i16;
import 'package:flutter/material.dart' as _i17;
import 'package:heroes_app/src/domain/models/promotion_model.dart' as _i18;
import 'package:heroes_app/src/presentation/pages/auth/auth_view.dart' as _i1;
import 'package:heroes_app/src/presentation/pages/auth/pages/first_time_view.dart'
    as _i7;
import 'package:heroes_app/src/presentation/pages/auth/pages/login_view.dart'
    as _i8;
import 'package:heroes_app/src/presentation/pages/auth/pages/restore_password_view.dart'
    as _i11;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_business.dart'
    as _i13;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_view.dart'
    as _i14;
import 'package:heroes_app/src/presentation/pages/dashboard/dashboard_view.dart'
    as _i3;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/favorites_view.dart'
    as _i6;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/edit_profile_view.dart'
    as _i4;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/profile_view.dart'
    as _i9;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/business_details_view.dart'
    as _i2;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/promotion_details_view.dart'
    as _i10;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/search_view.dart'
    as _i12;
import 'package:heroes_app/src/presentation/pages/entryPoint/entrypoint_view.dart'
    as _i5;
import 'package:heroes_app/src/presentation/pages/entryPoint/pages/unverified_user_view.dart'
    as _i15;

abstract class $AppRouter extends _i16.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i16.PageFactory> pagesMap = {
    AuthView.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AuthView(),
      );
    },
    BusinessDetailsView.name: (routeData) {
      final args = routeData.argsAs<BusinessDetailsViewArgs>();
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.BusinessDetailsView(
          key: args.key,
          businessId: args.businessId,
        ),
      );
    },
    DashBoardView.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.DashBoardView(),
      );
    },
    EditProfileView.name: (routeData) {
      final args = routeData.argsAs<EditProfileViewArgs>(
          orElse: () => const EditProfileViewArgs());
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.EditProfileView(key: args.key),
      );
    },
    EntryPointView.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.EntryPointView(),
      );
    },
    FavoritesView.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.FavoritesView(),
      );
    },
    FirstTimeView.name: (routeData) {
      final args = routeData.argsAs<FirstTimeViewArgs>(
          orElse: () => const FirstTimeViewArgs());
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.FirstTimeView(key: args.key),
      );
    },
    LoginView.name: (routeData) {
      final args = routeData.argsAs<LoginViewArgs>();
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.LoginView(
          key: args.key,
          onResult: args.onResult,
        ),
      );
    },
    ProfileView.name: (routeData) {
      final args = routeData.argsAs<ProfileViewArgs>(
          orElse: () => const ProfileViewArgs());
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i9.ProfileView(key: args.key),
      );
    },
    PromotionDetailsView.name: (routeData) {
      final args = routeData.argsAs<PromotionDetailsViewArgs>();
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i10.PromotionDetailsView(
          key: args.key,
          promotion: args.promotion,
        ),
      );
    },
    RestorePassword.name: (routeData) {
      final args = routeData.argsAs<RestorePasswordArgs>(
          orElse: () => const RestorePasswordArgs());
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i11.RestorePassword(key: args.key),
      );
    },
    SearchView.name: (routeData) {
      final args = routeData.argsAs<SearchViewArgs>(
          orElse: () => const SearchViewArgs());
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i12.SearchView(key: args.key),
      );
    },
    SignUpBusinessView.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i13.SignUpBusinessView(),
      );
    },
    SignUpView.name: (routeData) {
      final args = routeData.argsAs<SignUpViewArgs>();
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i14.SignUpView(
          key: args.key,
          onResult: args.onResult,
        ),
      );
    },
    UnverifiedUserView.name: (routeData) {
      final args = routeData.argsAs<UnverifiedUserViewArgs>(
          orElse: () => const UnverifiedUserViewArgs());
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i15.UnverifiedUserView(key: args.key),
      );
    },
  };
}

/// generated route for
/// [_i1.AuthView]
class AuthView extends _i16.PageRouteInfo<void> {
  const AuthView({List<_i16.PageRouteInfo>? children})
      : super(
          AuthView.name,
          initialChildren: children,
        );

  static const String name = 'AuthView';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i2.BusinessDetailsView]
class BusinessDetailsView extends _i16.PageRouteInfo<BusinessDetailsViewArgs> {
  BusinessDetailsView({
    _i17.Key? key,
    required String businessId,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          BusinessDetailsView.name,
          args: BusinessDetailsViewArgs(
            key: key,
            businessId: businessId,
          ),
          initialChildren: children,
        );

  static const String name = 'BusinessDetailsView';

  static const _i16.PageInfo<BusinessDetailsViewArgs> page =
      _i16.PageInfo<BusinessDetailsViewArgs>(name);
}

class BusinessDetailsViewArgs {
  const BusinessDetailsViewArgs({
    this.key,
    required this.businessId,
  });

  final _i17.Key? key;

  final String businessId;

  @override
  String toString() {
    return 'BusinessDetailsViewArgs{key: $key, businessId: $businessId}';
  }
}

/// generated route for
/// [_i3.DashBoardView]
class DashBoardView extends _i16.PageRouteInfo<void> {
  const DashBoardView({List<_i16.PageRouteInfo>? children})
      : super(
          DashBoardView.name,
          initialChildren: children,
        );

  static const String name = 'DashBoardView';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i4.EditProfileView]
class EditProfileView extends _i16.PageRouteInfo<EditProfileViewArgs> {
  EditProfileView({
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          EditProfileView.name,
          args: EditProfileViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'EditProfileView';

  static const _i16.PageInfo<EditProfileViewArgs> page =
      _i16.PageInfo<EditProfileViewArgs>(name);
}

class EditProfileViewArgs {
  const EditProfileViewArgs({this.key});

  final _i17.Key? key;

  @override
  String toString() {
    return 'EditProfileViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i5.EntryPointView]
class EntryPointView extends _i16.PageRouteInfo<void> {
  const EntryPointView({List<_i16.PageRouteInfo>? children})
      : super(
          EntryPointView.name,
          initialChildren: children,
        );

  static const String name = 'EntryPointView';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i6.FavoritesView]
class FavoritesView extends _i16.PageRouteInfo<void> {
  const FavoritesView({List<_i16.PageRouteInfo>? children})
      : super(
          FavoritesView.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesView';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i7.FirstTimeView]
class FirstTimeView extends _i16.PageRouteInfo<FirstTimeViewArgs> {
  FirstTimeView({
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          FirstTimeView.name,
          args: FirstTimeViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'FirstTimeView';

  static const _i16.PageInfo<FirstTimeViewArgs> page =
      _i16.PageInfo<FirstTimeViewArgs>(name);
}

class FirstTimeViewArgs {
  const FirstTimeViewArgs({this.key});

  final _i17.Key? key;

  @override
  String toString() {
    return 'FirstTimeViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i8.LoginView]
class LoginView extends _i16.PageRouteInfo<LoginViewArgs> {
  LoginView({
    _i17.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          LoginView.name,
          args: LoginViewArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginView';

  static const _i16.PageInfo<LoginViewArgs> page =
      _i16.PageInfo<LoginViewArgs>(name);
}

class LoginViewArgs {
  const LoginViewArgs({
    this.key,
    required this.onResult,
  });

  final _i17.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'LoginViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i9.ProfileView]
class ProfileView extends _i16.PageRouteInfo<ProfileViewArgs> {
  ProfileView({
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          ProfileView.name,
          args: ProfileViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ProfileView';

  static const _i16.PageInfo<ProfileViewArgs> page =
      _i16.PageInfo<ProfileViewArgs>(name);
}

class ProfileViewArgs {
  const ProfileViewArgs({this.key});

  final _i17.Key? key;

  @override
  String toString() {
    return 'ProfileViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i10.PromotionDetailsView]
class PromotionDetailsView
    extends _i16.PageRouteInfo<PromotionDetailsViewArgs> {
  PromotionDetailsView({
    _i17.Key? key,
    required _i18.Promotion promotion,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          PromotionDetailsView.name,
          args: PromotionDetailsViewArgs(
            key: key,
            promotion: promotion,
          ),
          initialChildren: children,
        );

  static const String name = 'PromotionDetailsView';

  static const _i16.PageInfo<PromotionDetailsViewArgs> page =
      _i16.PageInfo<PromotionDetailsViewArgs>(name);
}

class PromotionDetailsViewArgs {
  const PromotionDetailsViewArgs({
    this.key,
    required this.promotion,
  });

  final _i17.Key? key;

  final _i18.Promotion promotion;

  @override
  String toString() {
    return 'PromotionDetailsViewArgs{key: $key, promotion: $promotion}';
  }
}

/// generated route for
/// [_i11.RestorePassword]
class RestorePassword extends _i16.PageRouteInfo<RestorePasswordArgs> {
  RestorePassword({
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          RestorePassword.name,
          args: RestorePasswordArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'RestorePassword';

  static const _i16.PageInfo<RestorePasswordArgs> page =
      _i16.PageInfo<RestorePasswordArgs>(name);
}

class RestorePasswordArgs {
  const RestorePasswordArgs({this.key});

  final _i17.Key? key;

  @override
  String toString() {
    return 'RestorePasswordArgs{key: $key}';
  }
}

/// generated route for
/// [_i12.SearchView]
class SearchView extends _i16.PageRouteInfo<SearchViewArgs> {
  SearchView({
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          SearchView.name,
          args: SearchViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SearchView';

  static const _i16.PageInfo<SearchViewArgs> page =
      _i16.PageInfo<SearchViewArgs>(name);
}

class SearchViewArgs {
  const SearchViewArgs({this.key});

  final _i17.Key? key;

  @override
  String toString() {
    return 'SearchViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i13.SignUpBusinessView]
class SignUpBusinessView extends _i16.PageRouteInfo<void> {
  const SignUpBusinessView({List<_i16.PageRouteInfo>? children})
      : super(
          SignUpBusinessView.name,
          initialChildren: children,
        );

  static const String name = 'SignUpBusinessView';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i14.SignUpView]
class SignUpView extends _i16.PageRouteInfo<SignUpViewArgs> {
  SignUpView({
    _i17.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          SignUpView.name,
          args: SignUpViewArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'SignUpView';

  static const _i16.PageInfo<SignUpViewArgs> page =
      _i16.PageInfo<SignUpViewArgs>(name);
}

class SignUpViewArgs {
  const SignUpViewArgs({
    this.key,
    required this.onResult,
  });

  final _i17.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'SignUpViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i15.UnverifiedUserView]
class UnverifiedUserView extends _i16.PageRouteInfo<UnverifiedUserViewArgs> {
  UnverifiedUserView({
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          UnverifiedUserView.name,
          args: UnverifiedUserViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'UnverifiedUserView';

  static const _i16.PageInfo<UnverifiedUserViewArgs> page =
      _i16.PageInfo<UnverifiedUserViewArgs>(name);
}

class UnverifiedUserViewArgs {
  const UnverifiedUserViewArgs({this.key});

  final _i17.Key? key;

  @override
  String toString() {
    return 'UnverifiedUserViewArgs{key: $key}';
  }
}
