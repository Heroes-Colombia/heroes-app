import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';

import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'promotion_details_state.dart';

class PromotionDetailsCubit extends Cubit<PromotionDetailsState> {
  final locator = GetIt.instance;
  PromotionDetailsCubit() : super(const PromotionDetailsState());

  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  //This method is used to get the business details by ID and the promotions
  Future<void> getPromotionDetails(String promotionId) async {
    try {
      final firestoreService = locator.get<FirestoreService>();
      final promotionCollection =
          locator.get<AppConstants>().advertisementCollection;

      //We fetch the business details from the database
      final rawPromotion = await firestoreService.readDocumentByDocId(
        promotionCollection,
        promotionId,
      );

      final business = Promotion.fromJson(rawPromotion!);

      //We update the state with the new business details
      emit(state.copyWith(
        promotionId: promotionId,
        promotion: business,
        status: BusinessViewCubitStatus.success,
      ));
    } catch (e) {
      log('Error: $e, Function: getPromotionDetails, File: promotion_details_cubit.dart',
          stackTrace: StackTrace.current);
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
    }
  }

  //This method is used to verify if the promotion is favourite
  void promotionIsMarkedAsFavorite(String promotionId) async {
    //We get the user favourite promotions list
    final user = await locator.get<AuthService>().getUser();
    final userFavouritePromotions = user!.favouritePromotions;

    if (userFavouritePromotions.contains(promotionId)) {
      emit(state.copyWith(isFavourite: true));
    } else {
      emit(state.copyWith(isFavourite: false));
    }
  }

  //This method is used to set the promotion as favourite
  // CRITICAL FIX: Remove optimistic update to prevent flickering on errors
  void setPromotionAsFavourite(String promotionId) async {
    // Show loading state only (don't change favorite status yet)
    emit(state.copyWith(favouriteIsLoading: true));

    try {
      //We get the user id and the user favourite promotions list
      final user = await locator.get<AuthService>().getUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userId = user.uid;
      final userFavouritePromotions = user.favouritePromotions;

      //We create a copy of the user favourite promotions list
      final copyOfUserFavouritePromotions = [...userFavouritePromotions];

      final firestoreService = locator.get<FirestoreService>();
      final userCollection = locator.get<AppConstants>().usersCollection;

      //Check if the promotion was already favorited
      final wasFavorite = copyOfUserFavouritePromotions.contains(promotionId);

      //We check if the promotion is already marked as favourite
      if (wasFavorite) {
        //If it is, we remove it from the list
        copyOfUserFavouritePromotions.remove(promotionId);
      } else {
        //If it is not, we add it to the list
        copyOfUserFavouritePromotions.add(promotionId);
      }

      //We update the user favourite promotions list - WRITE TO FIRESTORE FIRST
      await firestoreService.editDocumentById(userCollection, userId, 'uid', {
        'favourite_promotions': copyOfUserFavouritePromotions,
      });

      //Update state AFTER successful Firestore write
      emit(state.copyWith(
        isFavourite: !wasFavorite,
        favouriteIsLoading: false,
      ));
    } catch (e) {
      //If the update fails, revert to original state (don't change favorite status)
      emit(state.copyWith(favouriteIsLoading: false));
      log(
        'Error: $e, Function: setPromotionAsFavourite, File: promotion_details_cubit.dart',
      );
    }
  }
}
