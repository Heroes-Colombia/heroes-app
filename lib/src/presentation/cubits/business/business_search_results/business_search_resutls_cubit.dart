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

  //This method is used to search a business from the firestore service
  void searchBusinesses(String query) async {
    emit(state.copyWith(isSearching: true));

    //We get the collection name from the app constants and we capitalize the query
    var searchQuery = locator<AppMethods>().capitalize(query);
    final businessCollection = locator<AppConstants>().businessCollection;

    //We get the businesses from the firestore service
    var rawSearchResults = await locator
        .get<FirestoreService>()
        .readActiveDocumentsBySearchQuery(
            businessCollection, "name", searchQuery);

    //We convert the raw businesses to a list of ListableBusiness
    final filteredBusinesses = rawSearchResults
        .map((business) => ListableBusiness.fromJson(business))
        .toList();

    //We emit the state with the new businesses
    emit(state.copyWith(businesses: filteredBusinesses, isSearching: false));
  }
}
