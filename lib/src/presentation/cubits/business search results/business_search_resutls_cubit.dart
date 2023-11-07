import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'business_search_resutls_state.dart';

class BusinessSearchResutlsCubit extends Cubit<BusinessSearchResutlsState> {
  BusinessSearchResutlsCubit() : super(const BusinessSearchResutlsState());
  final locator = GetIt.instance;

  void searchBusinesses(String query) async {
    emit(state.copyWith(isSearching: true));
    var searchQuery = locator<AppMethods>().capitalize(query);
    final businessCollection = locator<AppConstants>().businessCollection;

    var rawSearchResults = await locator
        .get<FirestoreService>()
        .readActiveDocumentsBySearchQuery(
            businessCollection, "name", searchQuery);

    final filteredBusinesses = rawSearchResults
        .map((business) => ListableBusiness.fromJson(business))
        .toList();
    emit(state.copyWith(businesses: filteredBusinesses, isSearching: false));
  }
}
