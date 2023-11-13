import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'business_details_state.dart';

class BusinessDetailsCubit extends Cubit<BusinessDetailsState> {
  final locator = GetIt.instance;
  BusinessDetailsCubit() : super(const BusinessDetailsState());

  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  //This method is used to get the business details by ID and the promotions
  Future<void> getBusinessDetails(String businessId) async {
    try {
      final firestoreService = locator.get<FirestoreService>();
      final businessCollection = locator.get<AppConstants>().businessCollection;

      //We fetch the business details from the database
      final rawBusiness = await firestoreService.readDocumentByDocId(
        businessCollection,
        businessId,
      );

      final business = Business.fromJson(rawBusiness!);

      //We fetch the promotions from the database
      final promotions = await getBusinessPromotions(businessId);

      //We update the state with the new business details
      emit(state.copyWith(
        businessId: businessId,
        business: business,
        promotions: promotions,
        status: BusinessViewCubitStatus.success,
        isFavourite: state.isFavourite,
        favouriteIsLoading: state.favouriteIsLoading,
      ));
    } catch (e) {
      log('Error: $e, Function: getBusinessDetails, File: business_details_cubit.dart',
          stackTrace: StackTrace.current);
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
    }
  }

  //this method is used to get the promotions of a business
  Future<List<Promotion>> getBusinessPromotions(String businessId) async {
    try {
      final firestoreService = locator.get<FirestoreService>();
      final promotionsCollection =
          locator.get<AppConstants>().advertisementCollection;

      //We fetch the promotions from the database
      final rawPromotions =
          await firestoreService.readActiveDocumentsByCondition(
              promotionsCollection, 'business_id', businessId, 999);

      final promotions =
          rawPromotions.map((e) => Promotion.fromJson(e)).toList();

      //Then return the promotions
      return promotions;
    } catch (e) {
      log('Error: $e, Function: getBusinessPromotions, File: business_details_cubit.dart');
      return [];
    }
  }

  //This method is used to verify if the business is favourite
  void businessIsMarkedAsFavorite(String businessId) async {
    //We get the user favourite businesses list
    final user = await locator.get<AuthService>().getUser();
    final userFavouriteBusinesses = user!.favouriteBusinesses;

    if (userFavouriteBusinesses.contains(businessId)) {
      emit(state.copyWith(isFavourite: true));
    } else {
      emit(state.copyWith(isFavourite: false));
    }
  }

  //This method is used to set the business as favourite
  void setBusinessAsFavourite(String businessId) async {
    //We update the state
    emit(state.copyWith(
      favouriteIsLoading: true,
      isFavourite: !state.isFavourite,
    ));

    try {
      //We get the user id and the user favourite businesses list
      final user = await locator.get<AuthService>().getUser();
      final userId = user!.uid;
      final userFavouriteBusinesses = user.favouriteBusinesses;

      //We create a copy of the user favourite businesses list
      final copyOfUserFavouriteBusinesses = [...userFavouriteBusinesses];

      final firestoreService = locator.get<FirestoreService>();
      final userCollection = locator.get<AppConstants>().usersCollection;

      //We check if the business is already marked as favourite
      if (copyOfUserFavouriteBusinesses.contains(businessId)) {
        //If it is, we remove it from the list
        copyOfUserFavouriteBusinesses.remove(businessId);
      } else {
        //If it is not, we add it to the list
        copyOfUserFavouriteBusinesses.add(businessId);
      }

      //We update the user favourite businesses list
      await firestoreService.editDocumentById(
        userCollection,
        userId,
        'uid',
        {'favourite_businesses': copyOfUserFavouriteBusinesses},
      );

      //We update the state
      emit(state.copyWith(isFavourite: state.isFavourite));
    } catch (e) {
      //If the update fails, we revert the state
      emit(state.copyWith(isFavourite: !state.isFavourite));
      log('Error: $e, Function: setBusinessAsFavourite, File: business_details_cubit.dart');
    }
  }
}
