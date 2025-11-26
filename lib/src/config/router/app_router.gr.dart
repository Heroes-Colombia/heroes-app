// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i29;
import 'package:flutter/material.dart' as _i30;
import 'package:heroes_app/src/domain/models/business_filter.dart' as _i31;
import 'package:heroes_app/src/domain/models/promotion_filter.dart' as _i32;
import 'package:heroes_app/src/domain/models/promotion_model.dart' as _i34;
import 'package:heroes_app/src/presentation/pages/auth/auth_view.dart' as _i3;
import 'package:heroes_app/src/presentation/pages/auth/pages/first_time_view.dart'
    as _i12;
import 'package:heroes_app/src/presentation/pages/auth/pages/login_view.dart'
    as _i14;
import 'package:heroes_app/src/presentation/pages/auth/pages/military_verification_view.dart'
    as _i16;
import 'package:heroes_app/src/presentation/pages/auth/pages/restore_password_view.dart'
    as _i23;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_business.dart'
    as _i25;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_view.dart'
    as _i26;
import 'package:heroes_app/src/presentation/pages/business_dashboard/business_dashboard_view.dart'
    as _i5;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/business_analytics_view.dart'
    as _i4;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/owned_business_details_view.dart'
    as _i17;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/owned_businesses_view.dart'
    as _i18;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/owned_promotion_details_view.dart'
    as _i19;
import 'package:heroes_app/src/presentation/pages/dashboard/dashboard_view.dart'
    as _i7;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/favorites_view.dart'
    as _i11;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/map/map_view.dart'
    as _i15;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/details_profile_view.dart'
    as _i8;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/edit_profile_view.dart'
    as _i9;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/profile_view.dart'
    as _i21;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/all_business_view.dart'
    as _i1;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/all_promotions_view.dart'
    as _i2;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/business_details_view.dart'
    as _i6;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/home_search_view.dart'
    as _i13;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/promotion_details_view.dart'
    as _i22;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/search_view.dart'
    as _i24;
import 'package:heroes_app/src/presentation/pages/entryPoint/entrypoint_view.dart'
    as _i10;
import 'package:heroes_app/src/presentation/pages/entryPoint/pages/unverified_user_view.dart'
    as _i28;
import 'package:heroes_app/src/presentation/pages/legal/privacy_policy_view.dart'
    as _i20;
import 'package:heroes_app/src/presentation/pages/legal/terms_and_conditions_view.dart'
    as _i27;
import 'package:location/location.dart' as _i33;

/// generated route for
/// [_i1.AllBusinessView]
class AllBusinessView extends _i29.PageRouteInfo<AllBusinessViewArgs> {
  AllBusinessView({
    _i30.Key? key,
    String? initialCategoryId,
    _i31.BusinessFilter? filter,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         AllBusinessView.name,
         args: AllBusinessViewArgs(
           key: key,
           initialCategoryId: initialCategoryId,
           filter: filter,
         ),
         initialChildren: children,
       );

  static const String name = 'AllBusinessView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AllBusinessViewArgs>(
        orElse: () => const AllBusinessViewArgs(),
      );
      return _i1.AllBusinessView(
        key: args.key,
        initialCategoryId: args.initialCategoryId,
        filter: args.filter,
      );
    },
  );
}

class AllBusinessViewArgs {
  const AllBusinessViewArgs({this.key, this.initialCategoryId, this.filter});

  final _i30.Key? key;

  final String? initialCategoryId;

  final _i31.BusinessFilter? filter;

  @override
  String toString() {
    return 'AllBusinessViewArgs{key: $key, initialCategoryId: $initialCategoryId, filter: $filter}';
  }
}

/// generated route for
/// [_i2.AllPromotionsView]
class AllPromotionsView extends _i29.PageRouteInfo<AllPromotionsViewArgs> {
  AllPromotionsView({
    _i30.Key? key,
    String? initialCategoryId,
    _i32.PromotionFilter? filter,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         AllPromotionsView.name,
         args: AllPromotionsViewArgs(
           key: key,
           initialCategoryId: initialCategoryId,
           filter: filter,
         ),
         initialChildren: children,
       );

  static const String name = 'AllPromotionsView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AllPromotionsViewArgs>(
        orElse: () => const AllPromotionsViewArgs(),
      );
      return _i2.AllPromotionsView(
        key: args.key,
        initialCategoryId: args.initialCategoryId,
        filter: args.filter,
      );
    },
  );
}

class AllPromotionsViewArgs {
  const AllPromotionsViewArgs({this.key, this.initialCategoryId, this.filter});

  final _i30.Key? key;

  final String? initialCategoryId;

  final _i32.PromotionFilter? filter;

  @override
  String toString() {
    return 'AllPromotionsViewArgs{key: $key, initialCategoryId: $initialCategoryId, filter: $filter}';
  }
}

/// generated route for
/// [_i3.AuthView]
class AuthView extends _i29.PageRouteInfo<void> {
  const AuthView({List<_i29.PageRouteInfo>? children})
    : super(AuthView.name, initialChildren: children);

  static const String name = 'AuthView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i3.AuthView();
    },
  );
}

/// generated route for
/// [_i4.BusinessAnalyticsView]
class BusinessAnalyticsView
    extends _i29.PageRouteInfo<BusinessAnalyticsViewArgs> {
  BusinessAnalyticsView({
    _i30.Key? key,
    required String businessId,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         BusinessAnalyticsView.name,
         args: BusinessAnalyticsViewArgs(key: key, businessId: businessId),
         initialChildren: children,
       );

  static const String name = 'BusinessAnalyticsView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BusinessAnalyticsViewArgs>();
      return _i4.BusinessAnalyticsView(
        key: args.key,
        businessId: args.businessId,
      );
    },
  );
}

class BusinessAnalyticsViewArgs {
  const BusinessAnalyticsViewArgs({this.key, required this.businessId});

  final _i30.Key? key;

  final String businessId;

  @override
  String toString() {
    return 'BusinessAnalyticsViewArgs{key: $key, businessId: $businessId}';
  }
}

/// generated route for
/// [_i5.BusinessDashBoardView]
class BusinessDashBoardView extends _i29.PageRouteInfo<void> {
  const BusinessDashBoardView({List<_i29.PageRouteInfo>? children})
    : super(BusinessDashBoardView.name, initialChildren: children);

  static const String name = 'BusinessDashBoardView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i5.BusinessDashBoardView();
    },
  );
}

/// generated route for
/// [_i6.BusinessDetailsView]
class BusinessDetailsView extends _i29.PageRouteInfo<BusinessDetailsViewArgs> {
  BusinessDetailsView({
    _i30.Key? key,
    required String businessId,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         BusinessDetailsView.name,
         args: BusinessDetailsViewArgs(key: key, businessId: businessId),
         initialChildren: children,
       );

  static const String name = 'BusinessDetailsView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BusinessDetailsViewArgs>();
      return _i6.BusinessDetailsView(
        key: args.key,
        businessId: args.businessId,
      );
    },
  );
}

class BusinessDetailsViewArgs {
  const BusinessDetailsViewArgs({this.key, required this.businessId});

  final _i30.Key? key;

  final String businessId;

  @override
  String toString() {
    return 'BusinessDetailsViewArgs{key: $key, businessId: $businessId}';
  }
}

/// generated route for
/// [_i7.DashBoardView]
class DashBoardView extends _i29.PageRouteInfo<DashBoardViewArgs> {
  DashBoardView({_i30.Key? key, List<_i29.PageRouteInfo>? children})
    : super(
        DashBoardView.name,
        args: DashBoardViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'DashBoardView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DashBoardViewArgs>(
        orElse: () => const DashBoardViewArgs(),
      );
      return _i7.DashBoardView(key: args.key);
    },
  );
}

class DashBoardViewArgs {
  const DashBoardViewArgs({this.key});

  final _i30.Key? key;

  @override
  String toString() {
    return 'DashBoardViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i8.DetailsProfileView]
class DetailsProfileView extends _i29.PageRouteInfo<DetailsProfileViewArgs> {
  DetailsProfileView({_i30.Key? key, List<_i29.PageRouteInfo>? children})
    : super(
        DetailsProfileView.name,
        args: DetailsProfileViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'DetailsProfileView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailsProfileViewArgs>(
        orElse: () => const DetailsProfileViewArgs(),
      );
      return _i8.DetailsProfileView(key: args.key);
    },
  );
}

class DetailsProfileViewArgs {
  const DetailsProfileViewArgs({this.key});

  final _i30.Key? key;

  @override
  String toString() {
    return 'DetailsProfileViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i9.EditProfileView]
class EditProfileView extends _i29.PageRouteInfo<EditProfileViewArgs> {
  EditProfileView({_i30.Key? key, List<_i29.PageRouteInfo>? children})
    : super(
        EditProfileView.name,
        args: EditProfileViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'EditProfileView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileViewArgs>(
        orElse: () => const EditProfileViewArgs(),
      );
      return _i9.EditProfileView(key: args.key);
    },
  );
}

class EditProfileViewArgs {
  const EditProfileViewArgs({this.key});

  final _i30.Key? key;

  @override
  String toString() {
    return 'EditProfileViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i10.EntryPointView]
class EntryPointView extends _i29.PageRouteInfo<void> {
  const EntryPointView({List<_i29.PageRouteInfo>? children})
    : super(EntryPointView.name, initialChildren: children);

  static const String name = 'EntryPointView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i10.EntryPointView();
    },
  );
}

/// generated route for
/// [_i11.FavoritesView]
class FavoritesView extends _i29.PageRouteInfo<void> {
  const FavoritesView({List<_i29.PageRouteInfo>? children})
    : super(FavoritesView.name, initialChildren: children);

  static const String name = 'FavoritesView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i11.FavoritesView();
    },
  );
}

/// generated route for
/// [_i12.FirstTimeView]
class FirstTimeView extends _i29.PageRouteInfo<FirstTimeViewArgs> {
  FirstTimeView({_i30.Key? key, List<_i29.PageRouteInfo>? children})
    : super(
        FirstTimeView.name,
        args: FirstTimeViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'FirstTimeView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FirstTimeViewArgs>(
        orElse: () => const FirstTimeViewArgs(),
      );
      return _i12.FirstTimeView(key: args.key);
    },
  );
}

class FirstTimeViewArgs {
  const FirstTimeViewArgs({this.key});

  final _i30.Key? key;

  @override
  String toString() {
    return 'FirstTimeViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i13.HomeSearchView]
class HomeSearchView extends _i29.PageRouteInfo<void> {
  const HomeSearchView({List<_i29.PageRouteInfo>? children})
    : super(HomeSearchView.name, initialChildren: children);

  static const String name = 'HomeSearchView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i13.HomeSearchView();
    },
  );
}

/// generated route for
/// [_i14.LoginView]
class LoginView extends _i29.PageRouteInfo<LoginViewArgs> {
  LoginView({
    _i30.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         LoginView.name,
         args: LoginViewArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'LoginView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginViewArgs>();
      return _i14.LoginView(key: args.key, onResult: args.onResult);
    },
  );
}

class LoginViewArgs {
  const LoginViewArgs({this.key, required this.onResult});

  final _i30.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'LoginViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i15.MapView]
class MapView extends _i29.PageRouteInfo<MapViewArgs> {
  MapView({
    _i30.Key? key,
    required _i33.LocationData? initialCameraLocation,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         MapView.name,
         args: MapViewArgs(
           key: key,
           initialCameraLocation: initialCameraLocation,
         ),
         initialChildren: children,
       );

  static const String name = 'MapView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MapViewArgs>();
      return _i15.MapView(
        key: args.key,
        initialCameraLocation: args.initialCameraLocation,
      );
    },
  );
}

class MapViewArgs {
  const MapViewArgs({this.key, required this.initialCameraLocation});

  final _i30.Key? key;

  final _i33.LocationData? initialCameraLocation;

  @override
  String toString() {
    return 'MapViewArgs{key: $key, initialCameraLocation: $initialCameraLocation}';
  }
}

/// generated route for
/// [_i16.MilitaryVerificationView]
class MilitaryVerificationView
    extends _i29.PageRouteInfo<MilitaryVerificationViewArgs> {
  MilitaryVerificationView({
    _i30.Key? key,
    required Map<String, String> userEnteredData,
    required String userId,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         MilitaryVerificationView.name,
         args: MilitaryVerificationViewArgs(
           key: key,
           userEnteredData: userEnteredData,
           userId: userId,
         ),
         initialChildren: children,
       );

  static const String name = 'MilitaryVerificationView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MilitaryVerificationViewArgs>();
      return _i16.MilitaryVerificationView(
        key: args.key,
        userEnteredData: args.userEnteredData,
        userId: args.userId,
      );
    },
  );
}

class MilitaryVerificationViewArgs {
  const MilitaryVerificationViewArgs({
    this.key,
    required this.userEnteredData,
    required this.userId,
  });

  final _i30.Key? key;

  final Map<String, String> userEnteredData;

  final String userId;

  @override
  String toString() {
    return 'MilitaryVerificationViewArgs{key: $key, userEnteredData: $userEnteredData, userId: $userId}';
  }
}

/// generated route for
/// [_i17.OwnedBusinessDetailsView]
class OwnedBusinessDetailsView
    extends _i29.PageRouteInfo<OwnedBusinessDetailsViewArgs> {
  OwnedBusinessDetailsView({
    _i30.Key? key,
    required String businessId,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         OwnedBusinessDetailsView.name,
         args: OwnedBusinessDetailsViewArgs(key: key, businessId: businessId),
         initialChildren: children,
       );

  static const String name = 'OwnedBusinessDetailsView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OwnedBusinessDetailsViewArgs>();
      return _i17.OwnedBusinessDetailsView(
        key: args.key,
        businessId: args.businessId,
      );
    },
  );
}

class OwnedBusinessDetailsViewArgs {
  const OwnedBusinessDetailsViewArgs({this.key, required this.businessId});

  final _i30.Key? key;

  final String businessId;

  @override
  String toString() {
    return 'OwnedBusinessDetailsViewArgs{key: $key, businessId: $businessId}';
  }
}

/// generated route for
/// [_i18.OwnedBusinessesView]
class OwnedBusinessesView extends _i29.PageRouteInfo<OwnedBusinessesViewArgs> {
  OwnedBusinessesView({_i30.Key? key, List<_i29.PageRouteInfo>? children})
    : super(
        OwnedBusinessesView.name,
        args: OwnedBusinessesViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'OwnedBusinessesView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OwnedBusinessesViewArgs>(
        orElse: () => const OwnedBusinessesViewArgs(),
      );
      return _i18.OwnedBusinessesView(key: args.key);
    },
  );
}

class OwnedBusinessesViewArgs {
  const OwnedBusinessesViewArgs({this.key});

  final _i30.Key? key;

  @override
  String toString() {
    return 'OwnedBusinessesViewArgs{key: $key}';
  }
}

/// generated route for
/// [_i19.OwnedPromotionDetailsView]
class OwnedPromotionDetailsView
    extends _i29.PageRouteInfo<OwnedPromotionDetailsViewArgs> {
  OwnedPromotionDetailsView({
    _i30.Key? key,
    required _i34.Promotion promotion,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         OwnedPromotionDetailsView.name,
         args: OwnedPromotionDetailsViewArgs(key: key, promotion: promotion),
         initialChildren: children,
       );

  static const String name = 'OwnedPromotionDetailsView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OwnedPromotionDetailsViewArgs>();
      return _i19.OwnedPromotionDetailsView(
        key: args.key,
        promotion: args.promotion,
      );
    },
  );
}

class OwnedPromotionDetailsViewArgs {
  const OwnedPromotionDetailsViewArgs({this.key, required this.promotion});

  final _i30.Key? key;

  final _i34.Promotion promotion;

  @override
  String toString() {
    return 'OwnedPromotionDetailsViewArgs{key: $key, promotion: $promotion}';
  }
}

/// generated route for
/// [_i20.PrivacyPolicyView]
class PrivacyPolicyView extends _i29.PageRouteInfo<void> {
  const PrivacyPolicyView({List<_i29.PageRouteInfo>? children})
    : super(PrivacyPolicyView.name, initialChildren: children);

  static const String name = 'PrivacyPolicyView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i20.PrivacyPolicyView();
    },
  );
}

/// generated route for
/// [_i21.ProfileView]
class ProfileView extends _i29.PageRouteInfo<void> {
  const ProfileView({List<_i29.PageRouteInfo>? children})
    : super(ProfileView.name, initialChildren: children);

  static const String name = 'ProfileView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i21.ProfileView();
    },
  );
}

/// generated route for
/// [_i22.PromotionDetailsView]
class PromotionDetailsView
    extends _i29.PageRouteInfo<PromotionDetailsViewArgs> {
  PromotionDetailsView({
    _i30.Key? key,
    required _i34.Promotion? promotion,
    required String? promotionId,
    List<_i29.PageRouteInfo>? children,
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

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PromotionDetailsViewArgs>();
      return _i22.PromotionDetailsView(
        key: args.key,
        promotion: args.promotion,
        promotionId: args.promotionId,
      );
    },
  );
}

class PromotionDetailsViewArgs {
  const PromotionDetailsViewArgs({
    this.key,
    required this.promotion,
    required this.promotionId,
  });

  final _i30.Key? key;

  final _i34.Promotion? promotion;

  final String? promotionId;

  @override
  String toString() {
    return 'PromotionDetailsViewArgs{key: $key, promotion: $promotion, promotionId: $promotionId}';
  }
}

/// generated route for
/// [_i23.RestorePassword]
class RestorePassword extends _i29.PageRouteInfo<RestorePasswordArgs> {
  RestorePassword({_i30.Key? key, List<_i29.PageRouteInfo>? children})
    : super(
        RestorePassword.name,
        args: RestorePasswordArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'RestorePassword';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RestorePasswordArgs>(
        orElse: () => const RestorePasswordArgs(),
      );
      return _i23.RestorePassword(key: args.key);
    },
  );
}

class RestorePasswordArgs {
  const RestorePasswordArgs({this.key});

  final _i30.Key? key;

  @override
  String toString() {
    return 'RestorePasswordArgs{key: $key}';
  }
}

/// generated route for
/// [_i24.SearchView]
class SearchView extends _i29.PageRouteInfo<void> {
  const SearchView({List<_i29.PageRouteInfo>? children})
    : super(SearchView.name, initialChildren: children);

  static const String name = 'SearchView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i24.SearchView();
    },
  );
}

/// generated route for
/// [_i25.SignUpBusinessView]
class SignUpBusinessView extends _i29.PageRouteInfo<void> {
  const SignUpBusinessView({List<_i29.PageRouteInfo>? children})
    : super(SignUpBusinessView.name, initialChildren: children);

  static const String name = 'SignUpBusinessView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i25.SignUpBusinessView();
    },
  );
}

/// generated route for
/// [_i26.SignUpView]
class SignUpView extends _i29.PageRouteInfo<SignUpViewArgs> {
  SignUpView({
    _i30.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         SignUpView.name,
         args: SignUpViewArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'SignUpView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignUpViewArgs>();
      return _i26.SignUpView(key: args.key, onResult: args.onResult);
    },
  );
}

class SignUpViewArgs {
  const SignUpViewArgs({this.key, required this.onResult});

  final _i30.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'SignUpViewArgs{key: $key, onResult: $onResult}';
  }
}

/// generated route for
/// [_i27.TermsAndConditionsView]
class TermsAndConditionsView extends _i29.PageRouteInfo<void> {
  const TermsAndConditionsView({List<_i29.PageRouteInfo>? children})
    : super(TermsAndConditionsView.name, initialChildren: children);

  static const String name = 'TermsAndConditionsView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i27.TermsAndConditionsView();
    },
  );
}

/// generated route for
/// [_i28.UnverifiedUserView]
class UnverifiedUserView extends _i29.PageRouteInfo<UnverifiedUserViewArgs> {
  UnverifiedUserView({_i30.Key? key, List<_i29.PageRouteInfo>? children})
    : super(
        UnverifiedUserView.name,
        args: UnverifiedUserViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'UnverifiedUserView';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UnverifiedUserViewArgs>(
        orElse: () => const UnverifiedUserViewArgs(),
      );
      return _i28.UnverifiedUserView(key: args.key);
    },
  );
}

class UnverifiedUserViewArgs {
  const UnverifiedUserViewArgs({this.key});

  final _i30.Key? key;

  @override
  String toString() {
    return 'UnverifiedUserViewArgs{key: $key}';
  }
}
