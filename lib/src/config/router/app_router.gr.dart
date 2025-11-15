// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i28;
import 'package:collection/collection.dart' as _i31;
import 'package:flutter/material.dart' as _i29;
import 'package:heroes_app/src/domain/models/promotion_model.dart' as _i32;
import 'package:heroes_app/src/presentation/pages/auth/auth_view.dart' as _i2;
import 'package:heroes_app/src/presentation/pages/auth/pages/first_time_view.dart'
    as _i11;
import 'package:heroes_app/src/presentation/pages/auth/pages/login_view.dart'
    as _i13;
import 'package:heroes_app/src/presentation/pages/auth/pages/military_verification_view.dart'
    as _i15;
import 'package:heroes_app/src/presentation/pages/auth/pages/restore_password_view.dart'
    as _i22;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_business.dart'
    as _i24;
import 'package:heroes_app/src/presentation/pages/auth/pages/signup_view.dart'
    as _i25;
import 'package:heroes_app/src/presentation/pages/business_dashboard/business_dashboard_view.dart'
    as _i4;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/business_analytics_view.dart'
    as _i3;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/owned_business_details_view.dart'
    as _i16;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/owned_businesses_view.dart'
    as _i17;
import 'package:heroes_app/src/presentation/pages/business_dashboard/pages/owned_promotion_details_view.dart'
    as _i18;
import 'package:heroes_app/src/presentation/pages/dashboard/dashboard_view.dart'
    as _i6;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/favorites_view.dart'
    as _i10;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/map/map_view.dart'
    as _i14;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/details_profile_view.dart'
    as _i7;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/edit_profile_view.dart'
    as _i8;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/profile/profile_view.dart'
    as _i20;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/all_business_view.dart'
    as _i1;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/business_details_view.dart'
    as _i5;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/home_search_view.dart'
    as _i12;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/promotion_details_view.dart'
    as _i21;
import 'package:heroes_app/src/presentation/pages/dashboard/pages/search/search_view.dart'
    as _i23;
import 'package:heroes_app/src/presentation/pages/entryPoint/entrypoint_view.dart'
    as _i9;
import 'package:heroes_app/src/presentation/pages/entryPoint/pages/unverified_user_view.dart'
    as _i27;
import 'package:heroes_app/src/presentation/pages/legal/privacy_policy_view.dart'
    as _i19;
import 'package:heroes_app/src/presentation/pages/legal/terms_and_conditions_view.dart'
    as _i26;
import 'package:location/location.dart' as _i30;

/// generated route for
/// [_i1.AllBusinessView]
class AllBusinessView extends _i28.PageRouteInfo<AllBusinessViewArgs> {
  AllBusinessView({
    _i29.Key? key,
    String? initialCategoryId,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         AllBusinessView.name,
         args: AllBusinessViewArgs(
           key: key,
           initialCategoryId: initialCategoryId,
         ),
         initialChildren: children,
       );

  static const String name = 'AllBusinessView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AllBusinessViewArgs>(
        orElse: () => const AllBusinessViewArgs(),
      );
      return _i1.AllBusinessView(
        key: args.key,
        initialCategoryId: args.initialCategoryId,
      );
    },
  );
}

class AllBusinessViewArgs {
  const AllBusinessViewArgs({this.key, this.initialCategoryId});

  final _i29.Key? key;

  final String? initialCategoryId;

  @override
  String toString() {
    return 'AllBusinessViewArgs{key: $key, initialCategoryId: $initialCategoryId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AllBusinessViewArgs) return false;
    return key == other.key && initialCategoryId == other.initialCategoryId;
  }

  @override
  int get hashCode => key.hashCode ^ initialCategoryId.hashCode;
}

/// generated route for
/// [_i2.AuthView]
class AuthView extends _i28.PageRouteInfo<void> {
  const AuthView({List<_i28.PageRouteInfo>? children})
    : super(AuthView.name, initialChildren: children);

  static const String name = 'AuthView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i2.AuthView();
    },
  );
}

/// generated route for
/// [_i3.BusinessAnalyticsView]
class BusinessAnalyticsView
    extends _i28.PageRouteInfo<BusinessAnalyticsViewArgs> {
  BusinessAnalyticsView({
    _i29.Key? key,
    required String businessId,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         BusinessAnalyticsView.name,
         args: BusinessAnalyticsViewArgs(key: key, businessId: businessId),
         initialChildren: children,
       );

  static const String name = 'BusinessAnalyticsView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BusinessAnalyticsViewArgs>();
      return _i3.BusinessAnalyticsView(
        key: args.key,
        businessId: args.businessId,
      );
    },
  );
}

class BusinessAnalyticsViewArgs {
  const BusinessAnalyticsViewArgs({this.key, required this.businessId});

  final _i29.Key? key;

  final String businessId;

  @override
  String toString() {
    return 'BusinessAnalyticsViewArgs{key: $key, businessId: $businessId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BusinessAnalyticsViewArgs) return false;
    return key == other.key && businessId == other.businessId;
  }

  @override
  int get hashCode => key.hashCode ^ businessId.hashCode;
}

/// generated route for
/// [_i4.BusinessDashBoardView]
class BusinessDashBoardView extends _i28.PageRouteInfo<void> {
  const BusinessDashBoardView({List<_i28.PageRouteInfo>? children})
    : super(BusinessDashBoardView.name, initialChildren: children);

  static const String name = 'BusinessDashBoardView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i4.BusinessDashBoardView();
    },
  );
}

/// generated route for
/// [_i5.BusinessDetailsView]
class BusinessDetailsView extends _i28.PageRouteInfo<BusinessDetailsViewArgs> {
  BusinessDetailsView({
    _i29.Key? key,
    required String businessId,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         BusinessDetailsView.name,
         args: BusinessDetailsViewArgs(key: key, businessId: businessId),
         initialChildren: children,
       );

  static const String name = 'BusinessDetailsView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BusinessDetailsViewArgs>();
      return _i5.BusinessDetailsView(
        key: args.key,
        businessId: args.businessId,
      );
    },
  );
}

class BusinessDetailsViewArgs {
  const BusinessDetailsViewArgs({this.key, required this.businessId});

  final _i29.Key? key;

  final String businessId;

  @override
  String toString() {
    return 'BusinessDetailsViewArgs{key: $key, businessId: $businessId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BusinessDetailsViewArgs) return false;
    return key == other.key && businessId == other.businessId;
  }

  @override
  int get hashCode => key.hashCode ^ businessId.hashCode;
}

/// generated route for
/// [_i6.DashBoardView]
class DashBoardView extends _i28.PageRouteInfo<DashBoardViewArgs> {
  DashBoardView({_i29.Key? key, List<_i28.PageRouteInfo>? children})
    : super(
        DashBoardView.name,
        args: DashBoardViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'DashBoardView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DashBoardViewArgs>(
        orElse: () => const DashBoardViewArgs(),
      );
      return _i6.DashBoardView(key: args.key);
    },
  );
}

class DashBoardViewArgs {
  const DashBoardViewArgs({this.key});

  final _i29.Key? key;

  @override
  String toString() {
    return 'DashBoardViewArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DashBoardViewArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i7.DetailsProfileView]
class DetailsProfileView extends _i28.PageRouteInfo<DetailsProfileViewArgs> {
  DetailsProfileView({_i29.Key? key, List<_i28.PageRouteInfo>? children})
    : super(
        DetailsProfileView.name,
        args: DetailsProfileViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'DetailsProfileView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailsProfileViewArgs>(
        orElse: () => const DetailsProfileViewArgs(),
      );
      return _i7.DetailsProfileView(key: args.key);
    },
  );
}

class DetailsProfileViewArgs {
  const DetailsProfileViewArgs({this.key});

  final _i29.Key? key;

  @override
  String toString() {
    return 'DetailsProfileViewArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailsProfileViewArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i8.EditProfileView]
class EditProfileView extends _i28.PageRouteInfo<EditProfileViewArgs> {
  EditProfileView({_i29.Key? key, List<_i28.PageRouteInfo>? children})
    : super(
        EditProfileView.name,
        args: EditProfileViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'EditProfileView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileViewArgs>(
        orElse: () => const EditProfileViewArgs(),
      );
      return _i8.EditProfileView(key: args.key);
    },
  );
}

class EditProfileViewArgs {
  const EditProfileViewArgs({this.key});

  final _i29.Key? key;

  @override
  String toString() {
    return 'EditProfileViewArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProfileViewArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i9.EntryPointView]
class EntryPointView extends _i28.PageRouteInfo<void> {
  const EntryPointView({List<_i28.PageRouteInfo>? children})
    : super(EntryPointView.name, initialChildren: children);

  static const String name = 'EntryPointView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i9.EntryPointView();
    },
  );
}

/// generated route for
/// [_i10.FavoritesView]
class FavoritesView extends _i28.PageRouteInfo<void> {
  const FavoritesView({List<_i28.PageRouteInfo>? children})
    : super(FavoritesView.name, initialChildren: children);

  static const String name = 'FavoritesView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i10.FavoritesView();
    },
  );
}

/// generated route for
/// [_i11.FirstTimeView]
class FirstTimeView extends _i28.PageRouteInfo<FirstTimeViewArgs> {
  FirstTimeView({_i29.Key? key, List<_i28.PageRouteInfo>? children})
    : super(
        FirstTimeView.name,
        args: FirstTimeViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'FirstTimeView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FirstTimeViewArgs>(
        orElse: () => const FirstTimeViewArgs(),
      );
      return _i11.FirstTimeView(key: args.key);
    },
  );
}

class FirstTimeViewArgs {
  const FirstTimeViewArgs({this.key});

  final _i29.Key? key;

  @override
  String toString() {
    return 'FirstTimeViewArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FirstTimeViewArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i12.HomeSearchView]
class HomeSearchView extends _i28.PageRouteInfo<void> {
  const HomeSearchView({List<_i28.PageRouteInfo>? children})
    : super(HomeSearchView.name, initialChildren: children);

  static const String name = 'HomeSearchView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i12.HomeSearchView();
    },
  );
}

/// generated route for
/// [_i13.LoginView]
class LoginView extends _i28.PageRouteInfo<LoginViewArgs> {
  LoginView({
    _i29.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         LoginView.name,
         args: LoginViewArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'LoginView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginViewArgs>();
      return _i13.LoginView(key: args.key, onResult: args.onResult);
    },
  );
}

class LoginViewArgs {
  const LoginViewArgs({this.key, required this.onResult});

  final _i29.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'LoginViewArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginViewArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i14.MapView]
class MapView extends _i28.PageRouteInfo<MapViewArgs> {
  MapView({
    _i29.Key? key,
    required _i30.LocationData? initialCameraLocation,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         MapView.name,
         args: MapViewArgs(
           key: key,
           initialCameraLocation: initialCameraLocation,
         ),
         initialChildren: children,
       );

  static const String name = 'MapView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MapViewArgs>();
      return _i14.MapView(
        key: args.key,
        initialCameraLocation: args.initialCameraLocation,
      );
    },
  );
}

class MapViewArgs {
  const MapViewArgs({this.key, required this.initialCameraLocation});

  final _i29.Key? key;

  final _i30.LocationData? initialCameraLocation;

  @override
  String toString() {
    return 'MapViewArgs{key: $key, initialCameraLocation: $initialCameraLocation}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MapViewArgs) return false;
    return key == other.key &&
        initialCameraLocation == other.initialCameraLocation;
  }

  @override
  int get hashCode => key.hashCode ^ initialCameraLocation.hashCode;
}

/// generated route for
/// [_i15.MilitaryVerificationView]
class MilitaryVerificationView
    extends _i28.PageRouteInfo<MilitaryVerificationViewArgs> {
  MilitaryVerificationView({
    _i29.Key? key,
    required Map<String, String> userEnteredData,
    required String userId,
    List<_i28.PageRouteInfo>? children,
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

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MilitaryVerificationViewArgs>();
      return _i15.MilitaryVerificationView(
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

  final _i29.Key? key;

  final Map<String, String> userEnteredData;

  final String userId;

  @override
  String toString() {
    return 'MilitaryVerificationViewArgs{key: $key, userEnteredData: $userEnteredData, userId: $userId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MilitaryVerificationViewArgs) return false;
    return key == other.key &&
        const _i31.MapEquality().equals(
          userEnteredData,
          other.userEnteredData,
        ) &&
        userId == other.userId;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const _i31.MapEquality().hash(userEnteredData) ^
      userId.hashCode;
}

/// generated route for
/// [_i16.OwnedBusinessDetailsView]
class OwnedBusinessDetailsView
    extends _i28.PageRouteInfo<OwnedBusinessDetailsViewArgs> {
  OwnedBusinessDetailsView({
    _i29.Key? key,
    required String businessId,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         OwnedBusinessDetailsView.name,
         args: OwnedBusinessDetailsViewArgs(key: key, businessId: businessId),
         initialChildren: children,
       );

  static const String name = 'OwnedBusinessDetailsView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OwnedBusinessDetailsViewArgs>();
      return _i16.OwnedBusinessDetailsView(
        key: args.key,
        businessId: args.businessId,
      );
    },
  );
}

class OwnedBusinessDetailsViewArgs {
  const OwnedBusinessDetailsViewArgs({this.key, required this.businessId});

  final _i29.Key? key;

  final String businessId;

  @override
  String toString() {
    return 'OwnedBusinessDetailsViewArgs{key: $key, businessId: $businessId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OwnedBusinessDetailsViewArgs) return false;
    return key == other.key && businessId == other.businessId;
  }

  @override
  int get hashCode => key.hashCode ^ businessId.hashCode;
}

/// generated route for
/// [_i17.OwnedBusinessesView]
class OwnedBusinessesView extends _i28.PageRouteInfo<OwnedBusinessesViewArgs> {
  OwnedBusinessesView({_i29.Key? key, List<_i28.PageRouteInfo>? children})
    : super(
        OwnedBusinessesView.name,
        args: OwnedBusinessesViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'OwnedBusinessesView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OwnedBusinessesViewArgs>(
        orElse: () => const OwnedBusinessesViewArgs(),
      );
      return _i17.OwnedBusinessesView(key: args.key);
    },
  );
}

class OwnedBusinessesViewArgs {
  const OwnedBusinessesViewArgs({this.key});

  final _i29.Key? key;

  @override
  String toString() {
    return 'OwnedBusinessesViewArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OwnedBusinessesViewArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i18.OwnedPromotionDetailsView]
class OwnedPromotionDetailsView
    extends _i28.PageRouteInfo<OwnedPromotionDetailsViewArgs> {
  OwnedPromotionDetailsView({
    _i29.Key? key,
    required _i32.Promotion promotion,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         OwnedPromotionDetailsView.name,
         args: OwnedPromotionDetailsViewArgs(key: key, promotion: promotion),
         initialChildren: children,
       );

  static const String name = 'OwnedPromotionDetailsView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OwnedPromotionDetailsViewArgs>();
      return _i18.OwnedPromotionDetailsView(
        key: args.key,
        promotion: args.promotion,
      );
    },
  );
}

class OwnedPromotionDetailsViewArgs {
  const OwnedPromotionDetailsViewArgs({this.key, required this.promotion});

  final _i29.Key? key;

  final _i32.Promotion promotion;

  @override
  String toString() {
    return 'OwnedPromotionDetailsViewArgs{key: $key, promotion: $promotion}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OwnedPromotionDetailsViewArgs) return false;
    return key == other.key && promotion == other.promotion;
  }

  @override
  int get hashCode => key.hashCode ^ promotion.hashCode;
}

/// generated route for
/// [_i19.PrivacyPolicyView]
class PrivacyPolicyView extends _i28.PageRouteInfo<void> {
  const PrivacyPolicyView({List<_i28.PageRouteInfo>? children})
    : super(PrivacyPolicyView.name, initialChildren: children);

  static const String name = 'PrivacyPolicyView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i19.PrivacyPolicyView();
    },
  );
}

/// generated route for
/// [_i20.ProfileView]
class ProfileView extends _i28.PageRouteInfo<void> {
  const ProfileView({List<_i28.PageRouteInfo>? children})
    : super(ProfileView.name, initialChildren: children);

  static const String name = 'ProfileView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i20.ProfileView();
    },
  );
}

/// generated route for
/// [_i21.PromotionDetailsView]
class PromotionDetailsView
    extends _i28.PageRouteInfo<PromotionDetailsViewArgs> {
  PromotionDetailsView({
    _i29.Key? key,
    required _i32.Promotion? promotion,
    required String? promotionId,
    List<_i28.PageRouteInfo>? children,
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

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PromotionDetailsViewArgs>();
      return _i21.PromotionDetailsView(
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

  final _i29.Key? key;

  final _i32.Promotion? promotion;

  final String? promotionId;

  @override
  String toString() {
    return 'PromotionDetailsViewArgs{key: $key, promotion: $promotion, promotionId: $promotionId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PromotionDetailsViewArgs) return false;
    return key == other.key &&
        promotion == other.promotion &&
        promotionId == other.promotionId;
  }

  @override
  int get hashCode => key.hashCode ^ promotion.hashCode ^ promotionId.hashCode;
}

/// generated route for
/// [_i22.RestorePassword]
class RestorePassword extends _i28.PageRouteInfo<RestorePasswordArgs> {
  RestorePassword({_i29.Key? key, List<_i28.PageRouteInfo>? children})
    : super(
        RestorePassword.name,
        args: RestorePasswordArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'RestorePassword';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RestorePasswordArgs>(
        orElse: () => const RestorePasswordArgs(),
      );
      return _i22.RestorePassword(key: args.key);
    },
  );
}

class RestorePasswordArgs {
  const RestorePasswordArgs({this.key});

  final _i29.Key? key;

  @override
  String toString() {
    return 'RestorePasswordArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RestorePasswordArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i23.SearchView]
class SearchView extends _i28.PageRouteInfo<SearchViewArgs> {
  SearchView({_i29.Key? key, List<_i28.PageRouteInfo>? children})
    : super(
        SearchView.name,
        args: SearchViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'SearchView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SearchViewArgs>(
        orElse: () => const SearchViewArgs(),
      );
      return _i23.SearchView(key: args.key);
    },
  );
}

class SearchViewArgs {
  const SearchViewArgs({this.key});

  final _i29.Key? key;

  @override
  String toString() {
    return 'SearchViewArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SearchViewArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i24.SignUpBusinessView]
class SignUpBusinessView extends _i28.PageRouteInfo<void> {
  const SignUpBusinessView({List<_i28.PageRouteInfo>? children})
    : super(SignUpBusinessView.name, initialChildren: children);

  static const String name = 'SignUpBusinessView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i24.SignUpBusinessView();
    },
  );
}

/// generated route for
/// [_i25.SignUpView]
class SignUpView extends _i28.PageRouteInfo<SignUpViewArgs> {
  SignUpView({
    _i29.Key? key,
    required dynamic Function(bool?) onResult,
    List<_i28.PageRouteInfo>? children,
  }) : super(
         SignUpView.name,
         args: SignUpViewArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'SignUpView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SignUpViewArgs>();
      return _i25.SignUpView(key: args.key, onResult: args.onResult);
    },
  );
}

class SignUpViewArgs {
  const SignUpViewArgs({this.key, required this.onResult});

  final _i29.Key? key;

  final dynamic Function(bool?) onResult;

  @override
  String toString() {
    return 'SignUpViewArgs{key: $key, onResult: $onResult}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignUpViewArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i26.TermsAndConditionsView]
class TermsAndConditionsView extends _i28.PageRouteInfo<void> {
  const TermsAndConditionsView({List<_i28.PageRouteInfo>? children})
    : super(TermsAndConditionsView.name, initialChildren: children);

  static const String name = 'TermsAndConditionsView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      return const _i26.TermsAndConditionsView();
    },
  );
}

/// generated route for
/// [_i27.UnverifiedUserView]
class UnverifiedUserView extends _i28.PageRouteInfo<UnverifiedUserViewArgs> {
  UnverifiedUserView({_i29.Key? key, List<_i28.PageRouteInfo>? children})
    : super(
        UnverifiedUserView.name,
        args: UnverifiedUserViewArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'UnverifiedUserView';

  static _i28.PageInfo page = _i28.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UnverifiedUserViewArgs>(
        orElse: () => const UnverifiedUserViewArgs(),
      );
      return _i27.UnverifiedUserView(key: args.key);
    },
  );
}

class UnverifiedUserViewArgs {
  const UnverifiedUserViewArgs({this.key});

  final _i29.Key? key;

  @override
  String toString() {
    return 'UnverifiedUserViewArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UnverifiedUserViewArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}
