// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i18;
import 'package:flutter/material.dart' as _i19;
import 'package:heroes_app/src/domain/models/promotion_model.dart' as _i20;
import 'package:heroes_app/src/presentation/pages/auth/auth_view.dart' as _i2;
import 'package:heroes_app/src/presentation/pages/auth/pages/first_time_view.dart'
    as _i8;
import 'package:heroes_app/src/presentation/pages/auth/pages/login_view.dart'
    as _i10;
import 'package:heroes_app/src/presentation/pages/auth/pages/restore_password_view.dart'
    as _i13;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_business.dart'
    as _i15;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_view.dart'
    as _i16;
import 'package:heroes_app/src/presentation/pages/dashboard/dashboard_view.dart'
    as _i4;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/favorites_view.dart'
    as _i7;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/edit_profile_view.dart'
    as _i5;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/profile_view.dart'
    as _i11;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/all_business_view.dart'
    as _i1;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/business_details_view.dart'
    as _i3;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/home_search_view.dart'
    as _i9;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/promotion_details_view.dart'
    as _i12;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/search_view.dart'
    as _i14;
import 'package:heroes_app/src/presentation/pages/entryPoint/entrypoint_view.dart'
    as _i6;
import 'package:heroes_app/src/presentation/pages/entryPoint/pages/unverified_user_view.dart'
    as _i17;

abstract class $AppRouter extends _i18.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i18.PageFactory> pagesMap = {
    AllBusinessView.name: (routeData) {
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AllBusinessView(),
      );
    },
    AuthView.name: (routeData) {
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.AuthView(),
      );
    },
    BusinessDetailsView.name: (routeData) {
      final args = routeData.argsAs<BusinessDetailsViewArgs>();
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.BusinessDetailsView(
          key: args.key,
          businessId: args.businessId,
        ),
      );
    },
    DashBoardView.name: (routeData) {
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.DashBoardView(),
      );
    },
    EditProfileView.name: (routeData) {
      final args = routeData.argsAs<EditProfileViewArgs>(
          orElse: () => const EditProfileViewArgs());
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i5.EditProfileView(key: args.key),
      );
    },
    EntryPointView.name: (routeData) {
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.EntryPointView(),
      );
    },
    FavoritesView.name: (routeData) {
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.FavoritesView(),
      );
    },
    FirstTimeView.name: (routeData) {
      final args = routeData.argsAs<FirstTimeViewArgs>(
          orElse: () => const FirstTimeViewArgs());
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.FirstTimeView(key: args.key),
      );
    },
    HomeSearchView.name: (routeData) {
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.HomeSearchView(),
      );
    },
    LoginView.name: (routeData) {
      final args = routeData.argsAs<LoginViewArgs>();
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i10.LoginView(
          key: args.key,
          onResult: args.onResult,
        ),
      );
    },
    ProfileView.name: (routeData) {
      final args = routeData.argsAs<ProfileViewArgs>(
          orElse: () => const ProfileViewArgs());
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i11.ProfileView(key: args.key),
      );
    },
    PromotionDetailsView.name: (routeData) {
      final args = routeData.argsAs<PromotionDetailsViewArgs>();
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i12.PromotionDetailsView(
          key: args.key,
          promotion: args.promotion,
        ),
      );
    },
    RestorePassword.name: (routeData) {
      final args = routeData.argsAs<RestorePasswordArgs>(
          orElse: () => const RestorePasswordArgs());
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i13.RestorePassword(key: args.key),
      );
    },
    SearchView.name: (routeData) {
      final args = routeData.argsAs<SearchViewArgs>(
          orElse: () => const SearchViewArgs());
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i14.SearchView(key: args.key),
      );
    },
    SignUpBusinessView.name: (routeData) {
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i15.SignUpBusinessView(),
      );
    },
    SignUpView.name: (routeData) {
      final args = routeData.argsAs<SignUpViewArgs>();
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i16.SignUpView(
          key: args.key,
          onResult: args.onResult,
        ),
      );
    },
    UnverifiedUserView.name: (routeData) {
      final args = routeData.argsAs<UnverifiedUserViewArgs>(
          orElse: () => const UnverifiedUserViewArgs());
      return _i18.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i17.UnverifiedUserView(key: args.key),
      );
    },
  };
}

/// generated route for
/// [_i1.AllBusinessView]
class AllBusinessView extends _i18.PageRouteInfo<void> {
  const AllBusinessView({List<_i18.PageRouteInfo>? children})
      : super(
          AllBusinessView.name,
          initialChildren: children,
        );

  static const String name = 'AllBusinessView';

  static const _i18.PageInfo<void> page = _i18.PageInfo<void>(name);
}

/// generated route for
/// [_i2.AuthView]
class AuthView extends _i18.PageRouteInfo<void> {
  const AuthView({List<_i18.PageRouteInfo>? children})
      : super(
          AuthView.name,
          initialChildren: children,
        );

  static const String name = 'AuthView';

  static const _i18.PageInfo<void> page = _i18.PageInfo<void>(name);
}

/// generated route for
/// [_i3.BusinessDetailsView]
class BusinessDetailsView extends _i18.PageRouteInfo<BusinessDetailsViewArgs> {
  BusinessDetailsView({
    _i19.Key? key,
    required String businessId,
    List<_i18.PageRouteInfo>? children,
  }) : super(
          BusinessDetailsView.name,
          args: BusinessDetailsViewArgs(
            key: key,
            businessId: businessId,
          ),
          initialChildren: children,
        );

  static const String name = 'BusinessDetailsView';

  static const _i18.PageInfo<BusinessDetailsViewArgs> page =
      _i18.PageInfo<BusinessDetailsViewArgs>(name);
}

class BusinessDetailsViewArgs {
  const BusinessDetailsViewArgs({
    this.key,
    required this.businessId,
  });

  final _i19.Key? key;

  final String businessId;

  @override
  String toString() {
    return 'BusinessDetailsViewArgs{key: $key, businessId: $businessId}';
  }
}

/// generated route for
/// [_i4.DashBoardView]
class DashBoardView extends _i18.PageRouteInfo<void> {
  const DashBoardView({List<_i18.PageRouteInfo>? children})
      : super(
          DashBoardView.name,
          initialChildren: children,
        );

  static const String name = 'DashBoardView';

  static const _i18.PageInfo<void> page = _i18.PageInfo<void>(name);
}

/// generated route for
/// [_i5.EditProfileView]
class EditProfileView extends _i18.PageRouteInfo<EditProfileViewArgs> {
  EditProfileView({
    _i19.Key? key,
    List<_i18.PageRouteInfo>? children,
  }) : super(
          EditProfileView.name,
          args: EditProfileViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'EditProfileView';

  static const _i18.PageInfo<EditProfileViewArgs> page =
      _i18.PageInfo<EditProfileViewArgs>(name);
}

class EditProfileViewArgs {
  const EditProfileViewArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'EditProfileViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i6.EntryPointView]
class EntryPointView extends _i18.PageRouteInfo<void> {
  const EntryPointView({List<_i18.PageRouteInfo>? children})
      : super(
          EntryPointView.name,
          initialChildren: children,
        );

  static const String name = 'EntryPointView';

  static const _i18.PageInfo<void> page = _i18.PageInfo<void>(name);
}

/// generated route for
/// [_i7.FavoritesView]
class FavoritesView extends _i18.PageRouteInfo<void> {
  const FavoritesView({List<_i18.PageRouteInfo>? children})
      : super(
          FavoritesView.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesView';

  static const _i18.PageInfo<void> page = _i18.PageInfo<void>(name);
}

/// generated route for
/// [_i8.FirstTimeView]
class FirstTimeView extends _i18.PageRouteInfo<FirstTimeViewArgs> {
  FirstTimeView({
    _i19.Key? key,
    List<_i18.PageRouteInfo>? children,
  }) : super(
          FirstTimeView.name,
          args: FirstTimeViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'FirstTimeView';

  static const _i18.PageInfo<FirstTimeViewArgs> page =
      _i18.PageInfo<FirstTimeViewArgs>(name);
}

class FirstTimeViewArgs {
  const FirstTimeViewArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'FirstTimeViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i9.HomeSearchView]
class HomeSearchView extends _i18.PageRouteInfo<void> {
  const HomeSearchView({List<_i18.PageRouteInfo>? children})
      : super(
          HomeSearchView.name,
          initialChildren: children,
        );

  static const String name = 'HomeSearchView';

  static const _i18.PageInfo<void> page = _i18.PageInfo<void>(name);
}

/// generated route for
/// [_i10.LoginView]
class LoginView extends _i18.PageRouteInfo<LoginViewArgs> {
  LoginView({
    _i19.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i18.PageRouteInfo>? children,
  }) : super(
          LoginView.name,
          args: LoginViewArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginView';

  static const _i18.PageInfo<LoginViewArgs> page =
      _i18.PageInfo<LoginViewArgs>(name);
}

class LoginViewArgs {
  const LoginViewArgs({
    this.key,
    required this.onResult,
  });

  final _i19.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'LoginViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i11.ProfileView]
class ProfileView extends _i18.PageRouteInfo<ProfileViewArgs> {
  ProfileView({
    _i19.Key? key,
    List<_i18.PageRouteInfo>? children,
  }) : super(
          ProfileView.name,
          args: ProfileViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ProfileView';

  static const _i18.PageInfo<ProfileViewArgs> page =
      _i18.PageInfo<ProfileViewArgs>(name);
}

class ProfileViewArgs {
  const ProfileViewArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'ProfileViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i12.PromotionDetailsView]
class PromotionDetailsView
    extends _i18.PageRouteInfo<PromotionDetailsViewArgs> {
  PromotionDetailsView({
    _i19.Key? key,
    required _i20.Promotion promotion,
    List<_i18.PageRouteInfo>? children,
  }) : super(
          PromotionDetailsView.name,
          args: PromotionDetailsViewArgs(
            key: key,
            promotion: promotion,
          ),
          initialChildren: children,
        );

  static const String name = 'PromotionDetailsView';

  static const _i18.PageInfo<PromotionDetailsViewArgs> page =
      _i18.PageInfo<PromotionDetailsViewArgs>(name);
}

class PromotionDetailsViewArgs {
  const PromotionDetailsViewArgs({
    this.key,
    required this.promotion,
  });

  final _i19.Key? key;

  final _i20.Promotion promotion;

  @override
  String toString() {
    return 'PromotionDetailsViewArgs{key: $key, promotion: $promotion}';
  }
}

/// generated route for
/// [_i13.RestorePassword]
class RestorePassword extends _i18.PageRouteInfo<RestorePasswordArgs> {
  RestorePassword({
    _i19.Key? key,
    List<_i18.PageRouteInfo>? children,
  }) : super(
          RestorePassword.name,
          args: RestorePasswordArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'RestorePassword';

  static const _i18.PageInfo<RestorePasswordArgs> page =
      _i18.PageInfo<RestorePasswordArgs>(name);
}

class RestorePasswordArgs {
  const RestorePasswordArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'RestorePasswordArgs{key: $key}';
  }
}

/// generated route for
/// [_i14.SearchView]
class SearchView extends _i18.PageRouteInfo<SearchViewArgs> {
  SearchView({
    _i19.Key? key,
    List<_i18.PageRouteInfo>? children,
  }) : super(
          SearchView.name,
          args: SearchViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SearchView';

  static const _i18.PageInfo<SearchViewArgs> page =
      _i18.PageInfo<SearchViewArgs>(name);
}

class SearchViewArgs {
  const SearchViewArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'SearchViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i15.SignUpBusinessView]
class SignUpBusinessView extends _i18.PageRouteInfo<void> {
  const SignUpBusinessView({List<_i18.PageRouteInfo>? children})
      : super(
          SignUpBusinessView.name,
          initialChildren: children,
        );

  static const String name = 'SignUpBusinessView';

  static const _i18.PageInfo<void> page = _i18.PageInfo<void>(name);
}

/// generated route for
/// [_i16.SignUpView]
class SignUpView extends _i18.PageRouteInfo<SignUpViewArgs> {
  SignUpView({
    _i19.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i18.PageRouteInfo>? children,
  }) : super(
          SignUpView.name,
          args: SignUpViewArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'SignUpView';

  static const _i18.PageInfo<SignUpViewArgs> page =
      _i18.PageInfo<SignUpViewArgs>(name);
}

class SignUpViewArgs {
  const SignUpViewArgs({
    this.key,
    required this.onResult,
  });

  final _i19.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'SignUpViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i17.UnverifiedUserView]
class UnverifiedUserView extends _i18.PageRouteInfo<UnverifiedUserViewArgs> {
  UnverifiedUserView({
    _i19.Key? key,
    List<_i18.PageRouteInfo>? children,
  }) : super(
          UnverifiedUserView.name,
          args: UnverifiedUserViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'UnverifiedUserView';

  static const _i18.PageInfo<UnverifiedUserViewArgs> page =
      _i18.PageInfo<UnverifiedUserViewArgs>(name);
}

class UnverifiedUserViewArgs {
  const UnverifiedUserViewArgs({this.key});

  final _i19.Key? key;

  @override
  String toString() {
    return 'UnverifiedUserViewArgs{key: $key}';
  }
}
