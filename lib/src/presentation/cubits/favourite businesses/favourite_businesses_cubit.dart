import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'favourite_businesses_state.dart';

class FavouriteBusinessesCubit extends Cubit<FavouriteBusinessesState> {
  FavouriteBusinessesCubit() : super(const FavouriteBusinessesState());
  final locator = GetIt.instance;

  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  void getFavouriteBusinesses() async {
    try {
      final collectionName = locator.get<AppConstants>().businessCollection;
      final user = await locator.get<AuthService>().getUser();

      final favouriteBusinesses = user!.favouriteBusinesses;

      final rawBusinesses = await locator<FirestoreService>()
          .readActiveDocumentsByDocumentIDs(
              collectionName, favouriteBusinesses);

      final businesses =
          rawBusinesses.map((e) => ListableBusiness.fromJson(e)).toList();

      emit(state.copyWith(
        status: BusinessViewCubitStatus.success,
        businesses: businesses,
      ));
    } catch (e) {
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
    }
  }
}
