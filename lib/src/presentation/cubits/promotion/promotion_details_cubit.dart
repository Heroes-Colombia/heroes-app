import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';

import 'package:heroes_app/src/domain/models/promotion_model.dart';
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
}
