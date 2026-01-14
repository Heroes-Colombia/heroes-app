import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'business_search_resutls_state.dart';

class BusinessSearchResutlsCubit extends Cubit<BusinessSearchResutlsState> {
  BusinessSearchResutlsCubit() : super(const BusinessSearchResutlsState());
  final locator = GetIt.instance;

  // Cached data for client-side filtering
  List<ListableBusiness>? _cachedBusinesses;
  List<Promotion>? _cachedPromotions;

  // This method searches both businesses and promotions with case-insensitive substring matching
  void searchBusinesses(String query) async {
    emit(state.copyWith(isSearching: true));

    try {
      final businessCollection = locator<AppConstants>().businessCollection;
      final promotionCollection = locator<AppConstants>().advertisementCollection;

      // Fetch all active businesses and promotions (cache them)
      if (_cachedBusinesses == null) {
        final rawBusinesses = await locator
            .get<FirestoreService>()
            .getAllActiveBusinessesForSearch(businessCollection);
        _cachedBusinesses = rawBusinesses
            .map((business) => ListableBusiness.fromJson(business))
            .toList();
      }

      if (_cachedPromotions == null) {
        final rawPromotions = await locator
            .get<FirestoreService>()
            .getAllActivePromotionsForSearch(promotionCollection);
        _cachedPromotions = rawPromotions
            .map((promotion) => Promotion.fromJson(promotion))
            .toList();
      }

      // Client-side filtering with case-insensitive multi-word matching
      final lowerQuery = query.toLowerCase().trim();

      // Split query into individual words for multi-word search
      final queryWords = lowerQuery.split(' ').where((word) => word.isNotEmpty).toList();

      // Filter businesses by name (matches if ANY word is found)
      final filteredBusinesses = _cachedBusinesses!
          .where((business) {
            final businessName = business.name.toLowerCase();
            // Return true if any query word is found in the business name
            return queryWords.any((word) => businessName.contains(word));
          })
          .toList();

      // Filter promotions by title (matches if ANY word is found)
      final filteredPromotions = _cachedPromotions!
          .where((promotion) {
            final promotionTitle = promotion.title.toLowerCase();
            // Return true if any query word is found in the promotion title
            return queryWords.any((word) => promotionTitle.contains(word));
          })
          .toList();

      // Emit the filtered results
      emit(state.copyWith(
        businesses: filteredBusinesses,
        promotions: filteredPromotions,
        isSearching: false,
      ));
    } catch (e) {
      // On error, emit empty results
      emit(state.copyWith(
        businesses: [],
        promotions: [],
        isSearching: false,
      ));
    }
  }

  // Method to refresh cached data (call this when you want to update the cache)
  void refreshCache() {
    _cachedBusinesses = null;
    _cachedPromotions = null;
  }
}
