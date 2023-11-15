import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'all_business_state.dart';

class AllBusinessCubit extends Cubit<AllBusinessState> {
  AllBusinessCubit() : super(const AllBusinessState());
  final locator = GetIt.instance;

  //This is the first method that is called when the cubit is created
  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  //This method is used to get all the businesses from the firestore service
  void getBusinesses() async {
    try {
      //We get the collection name from the app constants
      final collectionName = locator.get<AppConstants>().businessCollection;

      //We get the businesses from the firestore service
      final rawBusinesses = await locator<FirestoreService>()
          .readAllActiveDocuments(collectionName);

      //We convert the raw businesses to a list of ListableBusiness
      final businesses =
          rawBusinesses.map((e) => ListableBusiness.fromJson(e)).toList();

      //We emit the state with the new businesses
      emit(state.copyWith(
        status: BusinessViewCubitStatus.success,
        businesses: businesses,
      ));
    } catch (e) {
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
      log('Error: $e, Function: getBusinesses, File: all_business_cubit.dart');
    }
  }
}
