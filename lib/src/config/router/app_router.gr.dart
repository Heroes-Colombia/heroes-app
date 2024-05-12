// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i24;
import 'package:flutter/material.dart' as _i25;
import 'package:heroes_app/src/domain/models/promotion_model.dart' as _i27;
import 'package:heroes_app/src/presentation/pages/auth/auth_view.dart' as _i2;
import 'package:heroes_app/src/presentation/pages/auth/pages/first_time_view.dart'
    as _i10;
import 'package:heroes_app/src/presentation/pages/auth/pages/login_view.dart'
    as _i12;
import 'package:heroes_app/src/presentation/pages/auth/pages/restore_password_view.dart'
    as _i19;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_business.dart'
    as _i21;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_view.dart'
    as _i22;
import 'package:heroes_app/src/presentation/pages/business_dashboard/business_dashboard_view.dart'
    as _i3;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/owned_business_details_view.dart'
    as _i14;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/owned_businesses_view.dart'
    as _i15;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/owned_promotion_details_view.dart'
    as _i16;
import 'package:heroes_app/src/presentation/pages/dashboard/dashboard_view.dart'
    as _i5;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/favorites_view.dart'
    as _i9;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/map/map_view.dart'
    as _i13;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/details_profile_view.dart'
    as _i6;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/edit_profile_view.dart'
    as _i7;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/profile_view.dart'
    as _i17;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/all_business_view.dart'
    as _i1;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/business_details_view.dart'
    as _i4;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/home_search_view.dart'
    as _i11;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/promotion_details_view.dart'
    as _i18;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/search_view.dart'
    as _i20;
import 'package:heroes_app/src/presentation/pages/entryPoint/entrypoint_view.dart'
    as _i8;
import 'package:heroes_app/src/presentation/pages/entryPoint/pages/unverified_user_view.dart'
    as _i23;
import 'package:location/location.dart' as _i26;

abstract class $AppRouter extends _i24.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i24.PageFactory> pagesMap = {
    AllBusinessView.name: (routeData) {
      final args = routeData.argsAs<AllBusinessViewArgs>(
          orElse: () => const AllBusinessViewArgs());
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.AllBusinessView(
          key: args.key,
          initialCategoryId: args.initialCategoryId,
        ),
      );
    },
    AuthView.name: (routeData) {
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.AuthView(),
      );
    },
    BusinessDashBoardView.name: (routeData) {
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.BusinessDashBoardView(),
      );
    },
    BusinessDetailsView.name: (routeData) {
      final args = routeData.argsAs<BusinessDetailsViewArgs>();
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.BusinessDetailsView(
          key: args.key,
          businessId: args.businessId,
        ),
      );
    },
    DashBoardView.name: (routeData) {
      final args = routeData.argsAs<DashBoardViewArgs>(
          orElse: () => const DashBoardViewArgs());
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i5.DashBoardView(key: args.key),
      );
    },
    DetailsProfileView.name: (routeData) {
      final args = routeData.argsAs<DetailsProfileViewArgs>(
          orElse: () => const DetailsProfileViewArgs());
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i6.DetailsProfileView(key: args.key),
      );
    },
    EditProfileView.name: (routeData) {
      final args = routeData.argsAs<EditProfileViewArgs>(
          orElse: () => const EditProfileViewArgs());
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.EditProfileView(key: args.key),
      );
    },
    EntryPointView.name: (routeData) {
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.EntryPointView(),
      );
    },
    FavoritesView.name: (routeData) {
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.FavoritesView(),
      );
    },
    FirstTimeView.name: (routeData) {
      final args = routeData.argsAs<FirstTimeViewArgs>(
          orElse: () => const FirstTimeViewArgs());
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i10.FirstTimeView(key: args.key),
      );
    },
    HomeSearchView.name: (routeData) {
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.HomeSearchView(),
      );
    },
    LoginView.name: (routeData) {
      final args = routeData.argsAs<LoginViewArgs>();
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i12.LoginView(
          key: args.key,
          onResult: args.onResult,
        ),
      );
    },
    MapView.name: (routeData) {
      final args = routeData.argsAs<MapViewArgs>();
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i13.MapView(
          key: args.key,
          initialCameraLocation: args.initialCameraLocation,
        ),
      );
    },
    OwnedBusinessDetailsView.name: (routeData) {
      final args = routeData.argsAs<OwnedBusinessDetailsViewArgs>();
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i14.OwnedBusinessDetailsView(
          key: args.key,
          businessId: args.businessId,
        ),
      );
    },
    OwnedBusinessesView.name: (routeData) {
      final args = routeData.argsAs<OwnedBusinessesViewArgs>(
          orElse: () => const OwnedBusinessesViewArgs());
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i15.OwnedBusinessesView(key: args.key),
      );
    },
    OwnedPromotionDetailsView.name: (routeData) {
      final args = routeData.argsAs<OwnedPromotionDetailsViewArgs>();
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i16.OwnedPromotionDetailsView(
          key: args.key,
          promotion: args.promotion,
        ),
      );
    },
    ProfileView.name: (routeData) {
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i17.ProfileView(),
      );
    },
    PromotionDetailsView.name: (routeData) {
      final args = routeData.argsAs<PromotionDetailsViewArgs>();
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i18.PromotionDetailsView(
          key: args.key,
          promotion: args.promotion,
          promotionId: args.promotionId,
        ),
      );
    },
    RestorePassword.name: (routeData) {
      final args = routeData.argsAs<RestorePasswordArgs>(
          orElse: () => const RestorePasswordArgs());
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i19.RestorePassword(key: args.key),
      );
    },
    SearchView.name: (routeData) {
      final args = routeData.argsAs<SearchViewArgs>(
          orElse: () => const SearchViewArgs());
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i20.SearchView(key: args.key),
      );
    },
    SignUpBusinessView.name: (routeData) {
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i21.SignUpBusinessView(),
      );
    },
    SignUpView.name: (routeData) {
      final args = routeData.argsAs<SignUpViewArgs>();
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i22.SignUpView(
          key: args.key,
          onResult: args.onResult,
        ),
      );
    },
    UnverifiedUserView.name: (routeData) {
      final args = routeData.argsAs<UnverifiedUserViewArgs>(
          orElse: () => const UnverifiedUserViewArgs());
      return _i24.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i23.UnverifiedUserView(key: args.key),
      );
    },
  };
}

/// generated route for
/// [_i1.AllBusinessView]
class AllBusinessView extends _i24.PageRouteInfo<AllBusinessViewArgs> {
  AllBusinessView({
    _i25.Key? key,
    String? initialCategoryId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          AllBusinessView.name,
          args: AllBusinessViewArgs(
            key: key,
            initialCategoryId: initialCategoryId,
          ),
          initialChildren: children,
        );

  static const String name = 'AllBusinessView';

  static const _i24.PageInfo<AllBusinessViewArgs> page =
      _i24.PageInfo<AllBusinessViewArgs>(name);
}

class AllBusinessViewArgs {
  const AllBusinessViewArgs({
    this.key,
    this.initialCategoryId,
  });

  final _i25.Key? key;

  final String? initialCategoryId;

  @override
  String toString() {
    return 'AllBusinessViewArgs{key: $key, initialCategoryId: $initialCategoryId}';
  }
}

/// generated route for
/// [_i2.AuthView]
class AuthView extends _i24.PageRouteInfo<void> {
  const AuthView({List<_i24.PageRouteInfo>? children})
      : super(
          AuthView.name,
          initialChildren: children,
        );

  static const String name = 'AuthView';

  static const _i24.PageInfo<void> page = _i24.PageInfo<void>(name);
}

/// generated route for
/// [_i3.BusinessDashBoardView]
class BusinessDashBoardView extends _i24.PageRouteInfo<void> {
  const BusinessDashBoardView({List<_i24.PageRouteInfo>? children})
      : super(
          BusinessDashBoardView.name,
          initialChildren: children,
        );

  static const String name = 'BusinessDashBoardView';

  static const _i24.PageInfo<void> page = _i24.PageInfo<void>(name);
}

/// generated route for
/// [_i4.BusinessDetailsView]
class BusinessDetailsView extends _i24.PageRouteInfo<BusinessDetailsViewArgs> {
  BusinessDetailsView({
    _i25.Key? key,
    required String businessId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          BusinessDetailsView.name,
          args: BusinessDetailsViewArgs(
            key: key,
            businessId: businessId,
          ),
          initialChildren: children,
        );

  static const String name = 'BusinessDetailsView';

  static const _i24.PageInfo<BusinessDetailsViewArgs> page =
      _i24.PageInfo<BusinessDetailsViewArgs>(name);
}

class BusinessDetailsViewArgs {
  const BusinessDetailsViewArgs({
    this.key,
    required this.businessId,
  });

  final _i25.Key? key;

  final String businessId;

  @override
  String toString() {
    return 'BusinessDetailsViewArgs{key: $key, businessId: $businessId}';
  }
}

/// generated route for
/// [_i5.DashBoardView]
class DashBoardView extends _i24.PageRouteInfo<DashBoardViewArgs> {
  DashBoardView({
    _i25.Key? key,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          DashBoardView.name,
          args: DashBoardViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'DashBoardView';

  static const _i24.PageInfo<DashBoardViewArgs> page =
      _i24.PageInfo<DashBoardViewArgs>(name);
}

class DashBoardViewArgs {
  const DashBoardViewArgs({this.key});

  final _i25.Key? key;

  @override
  String toString() {
    return 'DashBoardViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i6.DetailsProfileView]
class DetailsProfileView extends _i24.PageRouteInfo<DetailsProfileViewArgs> {
  DetailsProfileView({
    _i25.Key? key,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          DetailsProfileView.name,
          args: DetailsProfileViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'DetailsProfileView';

  static const _i24.PageInfo<DetailsProfileViewArgs> page =
      _i24.PageInfo<DetailsProfileViewArgs>(name);
}

class DetailsProfileViewArgs {
  const DetailsProfileViewArgs({this.key});

  final _i25.Key? key;

  @override
  String toString() {
    return 'DetailsProfileViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i7.EditProfileView]
class EditProfileView extends _i24.PageRouteInfo<EditProfileViewArgs> {
  EditProfileView({
    _i25.Key? key,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          EditProfileView.name,
          args: EditProfileViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'EditProfileView';

  static const _i24.PageInfo<EditProfileViewArgs> page =
      _i24.PageInfo<EditProfileViewArgs>(name);
}

class EditProfileViewArgs {
  const EditProfileViewArgs({this.key});

  final _i25.Key? key;

  @override
  String toString() {
    return 'EditProfileViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i8.EntryPointView]
class EntryPointView extends _i24.PageRouteInfo<void> {
  const EntryPointView({List<_i24.PageRouteInfo>? children})
      : super(
          EntryPointView.name,
          initialChildren: children,
        );

  static const String name = 'EntryPointView';

  static const _i24.PageInfo<void> page = _i24.PageInfo<void>(name);
}

/// generated route for
/// [_i9.FavoritesView]
class FavoritesView extends _i24.PageRouteInfo<void> {
  const FavoritesView({List<_i24.PageRouteInfo>? children})
      : super(
          FavoritesView.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesView';

  static const _i24.PageInfo<void> page = _i24.PageInfo<void>(name);
}

/// generated route for
/// [_i10.FirstTimeView]
class FirstTimeView extends _i24.PageRouteInfo<FirstTimeViewArgs> {
  FirstTimeView({
    _i25.Key? key,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          FirstTimeView.name,
          args: FirstTimeViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'FirstTimeView';

  static const _i24.PageInfo<FirstTimeViewArgs> page =
      _i24.PageInfo<FirstTimeViewArgs>(name);
}

class FirstTimeViewArgs {
  const FirstTimeViewArgs({this.key});

  final _i25.Key? key;

  @override
  String toString() {
    return 'FirstTimeViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i11.HomeSearchView]
class HomeSearchView extends _i24.PageRouteInfo<void> {
  const HomeSearchView({List<_i24.PageRouteInfo>? children})
      : super(
          HomeSearchView.name,
          initialChildren: children,
        );

  static const String name = 'HomeSearchView';

  static const _i24.PageInfo<void> page = _i24.PageInfo<void>(name);
}

/// generated route for
/// [_i12.LoginView]
class LoginView extends _i24.PageRouteInfo<LoginViewArgs> {
  LoginView({
    _i25.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          LoginView.name,
          args: LoginViewArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginView';

  static const _i24.PageInfo<LoginViewArgs> page =
      _i24.PageInfo<LoginViewArgs>(name);
}

class LoginViewArgs {
  const LoginViewArgs({
    this.key,
    required this.onResult,
  });

  final _i25.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'LoginViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i13.MapView]
class MapView extends _i24.PageRouteInfo<MapViewArgs> {
  MapView({
    _i25.Key? key,
    required _i26.LocationData? initialCameraLocation,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          MapView.name,
          args: MapViewArgs(
            key: key,
            initialCameraLocation: initialCameraLocation,
          ),
          initialChildren: children,
        );

  static const String name = 'MapView';

  static const _i24.PageInfo<MapViewArgs> page =
      _i24.PageInfo<MapViewArgs>(name);
}

class MapViewArgs {
  const MapViewArgs({
    this.key,
    required this.initialCameraLocation,
  });

  final _i25.Key? key;

  final _i26.LocationData? initialCameraLocation;

  @override
  String toString() {
    return 'MapViewArgs{key: $key, initialCameraLocation: $initialCameraLocation}';
  }
}

/// generated route for
/// [_i14.OwnedBusinessDetailsView]
class OwnedBusinessDetailsView
    extends _i24.PageRouteInfo<OwnedBusinessDetailsViewArgs> {
  OwnedBusinessDetailsView({
    _i25.Key? key,
    required String businessId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          OwnedBusinessDetailsView.name,
          args: OwnedBusinessDetailsViewArgs(
            key: key,
            businessId: businessId,
          ),
          initialChildren: children,
        );

  static const String name = 'OwnedBusinessDetailsView';

  static const _i24.PageInfo<OwnedBusinessDetailsViewArgs> page =
      _i24.PageInfo<OwnedBusinessDetailsViewArgs>(name);
}

class OwnedBusinessDetailsViewArgs {
  const OwnedBusinessDetailsViewArgs({
    this.key,
    required this.businessId,
  });

  final _i25.Key? key;

  final String businessId;

  @override
  String toString() {
    return 'OwnedBusinessDetailsViewArgs{key: $key, businessId: $businessId}';
  }
}

/// generated route for
/// [_i15.OwnedBusinessesView]
class OwnedBusinessesView extends _i24.PageRouteInfo<OwnedBusinessesViewArgs> {
  OwnedBusinessesView({
    _i25.Key? key,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          OwnedBusinessesView.name,
          args: OwnedBusinessesViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'OwnedBusinessesView';

  static const _i24.PageInfo<OwnedBusinessesViewArgs> page =
      _i24.PageInfo<OwnedBusinessesViewArgs>(name);
}

class OwnedBusinessesViewArgs {
  const OwnedBusinessesViewArgs({this.key});

  final _i25.Key? key;

  @override
  String toString() {
    return 'OwnedBusinessesViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i16.OwnedPromotionDetailsView]
class OwnedPromotionDetailsView
    extends _i24.PageRouteInfo<OwnedPromotionDetailsViewArgs> {
  OwnedPromotionDetailsView({
    _i25.Key? key,
    required _i27.Promotion promotion,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          OwnedPromotionDetailsView.name,
          args: OwnedPromotionDetailsViewArgs(
            key: key,
            promotion: promotion,
          ),
          initialChildren: children,
        );

  static const String name = 'OwnedPromotionDetailsView';

  static const _i24.PageInfo<OwnedPromotionDetailsViewArgs> page =
      _i24.PageInfo<OwnedPromotionDetailsViewArgs>(name);
}

class OwnedPromotionDetailsViewArgs {
  const OwnedPromotionDetailsViewArgs({
    this.key,
    required this.promotion,
  });

  final _i25.Key? key;

  final _i27.Promotion promotion;

  @override
  String toString() {
    return 'OwnedPromotionDetailsViewArgs{key: $key, promotion: $promotion}';
  }
}

/// generated route for
/// [_i17.ProfileView]
class ProfileView extends _i24.PageRouteInfo<void> {
  const ProfileView({List<_i24.PageRouteInfo>? children})
      : super(
          ProfileView.name,
          initialChildren: children,
        );

  static const String name = 'ProfileView';

  static const _i24.PageInfo<void> page = _i24.PageInfo<void>(name);
}

/// generated route for
/// [_i18.PromotionDetailsView]
class PromotionDetailsView
    extends _i24.PageRouteInfo<PromotionDetailsViewArgs> {
  PromotionDetailsView({
    _i25.Key? key,
    required _i27.Promotion? promotion,
    required String? promotionId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          PromotionDetailsView.name,
          args: PromotionDetailsViewArgs(
            key: key,
            promotion: promotion,
            promotionId: promotionId,
          ),
          initialChildren: children,
        );

  static const String name = 'PromotionDetailsView';

  static const _i24.PageInfo<PromotionDetailsViewArgs> page =
      _i24.PageInfo<PromotionDetailsViewArgs>(name);
}

class PromotionDetailsViewArgs {
  const PromotionDetailsViewArgs({
    this.key,
    required this.promotion,
    required this.promotionId,
  });

  final _i25.Key? key;

  final _i27.Promotion? promotion;

  final String? promotionId;

  @override
  String toString() {
    return 'PromotionDetailsViewArgs{key: $key, promotion: $promotion, promotionId: $promotionId}';
  }
}

/// generated route for
/// [_i19.RestorePassword]
class RestorePassword extends _i24.PageRouteInfo<RestorePasswordArgs> {
  RestorePassword({
    _i25.Key? key,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          RestorePassword.name,
          args: RestorePasswordArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'RestorePassword';

  static const _i24.PageInfo<RestorePasswordArgs> page =
      _i24.PageInfo<RestorePasswordArgs>(name);
}

class RestorePasswordArgs {
  const RestorePasswordArgs({this.key});

  final _i25.Key? key;

  @override
  String toString() {
    return 'RestorePasswordArgs{key: $key}';
  }
}

/// generated route for
/// [_i20.SearchView]
class SearchView extends _i24.PageRouteInfo<SearchViewArgs> {
  SearchView({
    _i25.Key? key,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          SearchView.name,
          args: SearchViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SearchView';

  static const _i24.PageInfo<SearchViewArgs> page =
      _i24.PageInfo<SearchViewArgs>(name);
}

class SearchViewArgs {
  const SearchViewArgs({this.key});

  final _i25.Key? key;

  @override
  String toString() {
    return 'SearchViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i21.SignUpBusinessView]
class SignUpBusinessView extends _i24.PageRouteInfo<void> {
  const SignUpBusinessView({List<_i24.PageRouteInfo>? children})
      : super(
          SignUpBusinessView.name,
          initialChildren: children,
        );

  static const String name = 'SignUpBusinessView';

  static const _i24.PageInfo<void> page = _i24.PageInfo<void>(name);
}

/// generated route for
/// [_i22.SignUpView]
class SignUpView extends _i24.PageRouteInfo<SignUpViewArgs> {
  SignUpView({
    _i25.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          SignUpView.name,
          args: SignUpViewArgs(
            key: key,
            onResult: onResult,
          ),
          initialChildren: children,
        );

  static const String name = 'SignUpView';

  static const _i24.PageInfo<SignUpViewArgs> page =
      _i24.PageInfo<SignUpViewArgs>(name);
}

class SignUpViewArgs {
  const SignUpViewArgs({
    this.key,
    required this.onResult,
  });

  final _i25.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'SignUpViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i23.UnverifiedUserView]
class UnverifiedUserView extends _i24.PageRouteInfo<UnverifiedUserViewArgs> {
  UnverifiedUserView({
    _i25.Key? key,
    List<_i24.PageRouteInfo>? children,
  }) : super(
          UnverifiedUserView.name,
          args: UnverifiedUserViewArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'UnverifiedUserView';

  static const _i24.PageInfo<UnverifiedUserViewArgs> page =
      _i24.PageInfo<UnverifiedUserViewArgs>(name);
}

class UnverifiedUserViewArgs {
  const UnverifiedUserViewArgs({this.key});

  final _i25.Key? key;

  @override
  String toString() {
    return 'UnverifiedUserViewArgs{key: $key}';
  }
}
