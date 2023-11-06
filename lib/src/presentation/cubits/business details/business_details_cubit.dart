import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'business_details_state.dart';

class BusinessDetailsCubit extends Cubit<BusinessDetailsState> {
  final locator = GetIt.instance;
  BusinessDetailsCubit() : super(const BusinessDetailsState());

  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  //This method is used to get the business details by ID and the promotions
  void getBusinessDetails(String businessId) async {
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
}
