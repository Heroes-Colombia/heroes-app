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

  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  void getBusinesses() async {
    try {
      final collectionName = locator.get<AppConstants>().businessCollection;

      final rawBusinesses = await locator<FirestoreService>()
          .readAllActiveDocuments(collectionName);

      final businesses =
          rawBusinesses.map((e) => ListableBusiness.fromJson(e)).toList();

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
