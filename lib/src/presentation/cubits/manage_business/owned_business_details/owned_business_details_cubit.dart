import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/listable_user_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/models/review_model.dart';
import 'package:heroes_app/src/domain/repositories/firestorage_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:image_picker/image_picker.dart';

part 'owned_business_details_state.dart';

class OwnedBusinessDetailsCubit extends Cubit<OwnedBusinessDetailsState> {
  final locator = GetIt.instance;
  OwnedBusinessDetailsCubit() : super(const OwnedBusinessDetailsState());

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
      ));
    } catch (e) {
      log('Error: $e, Function: getBusinessDetails, File: owned_owned_business_details_cubit.dart',
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
      final rawPromotions = await firestoreService.readAllDocumentsInCollection(
          promotionsCollection, 'business_id', businessId);

      final promotions =
          rawPromotions.map((e) => Promotion.fromJson(e)).toList();

      //Then return the promotions
      return promotions;
    } catch (e) {
      log('Error: $e, Function: getBusinessPromotions, File: owned_business_details_cubit.dart');
      return [];
    }
  }

  //This method is used to get all business reviews
  Future<void> getAllBusinessReviews(String businessId) async {
    emit(state.copyWith(allUserReviews: []));
    try {
      final firestoreService = locator.get<FirestoreService>();
      final reviewsCollection = locator.get<AppConstants>().reviewsCollection;

      //We fetch the reviews from the database
      final rawReviews = await firestoreService.readActiveDocumentsByCondition(
          reviewsCollection, 'business_id', businessId, 999);

      final reviews = rawReviews.map((e) => UserReview.fromJson(e)).toList();

      //Then return the reviews
      emit(state.copyWith(allUserReviews: reviews));
    } catch (e) {
      log('Error: $e, Function: getAllBusinessReviews, File: owned_business_details_cubit.dart');
    }
  }

  Future<void> getAllBusinessManagers(String businessId) async {
    emit(state.copyWith(allUserReviews: []));
    try {
      final firestoreService = locator.get<FirestoreService>();
      final usersCollection = locator.get<AppConstants>().usersCollection;

      //We fetch all the users that contains the business id in their owned_businesses array
      final rawBusinessManagers =
          await firestoreService.readDocumentsWhereArrayContainsId(
              usersCollection, "owned_businesses", businessId);

      final managers = rawBusinessManagers
          .map((e) => ListableUserModel.fromJson(e))
          .toList();

      //Then return the reviews
      emit(state.copyWith(allManagers: managers));
    } catch (e) {
      log('Error: $e, Function: getAllBusinessManagers, File: owned_business_details_cubit.dart');
    }
  }

  Future<bool> createPromotion(Map<String, dynamic> promotionMap) async {
    try {
      //First, we create the promotion object
      var promotion = Promotion(
        documentId: null,
        title: promotionMap["title"]!.value,
        description: promotionMap["description"]!.value,
        instructions: promotionMap["instructions"]!.value,
        percentage: int.parse(promotionMap["percentage"]!.value),
        expiredAt: promotionMap["expirationDate"]!.value,
        featuredImage: "",
        businessId: promotionMap["business_id"]!,
        status: PromotionStatus.active,
      );

      //Then, we save the promotion in the database
      final firestoreService = locator.get<FirestoreService>();
      final promotionsCollection =
          locator.get<AppConstants>().advertisementCollection;

      final docId = await firestoreService.createDocument(
          promotionsCollection, promotion.toJson());

      //Then, we save the image in the firebase storage
      XFile image = promotionMap["featured_image"]!.value;

      final fireStorage = locator.get<FireStorageService>();
      final promotionFeaturedImagePath =
          await fireStorage.uploadPromotionFeaturedImage(image, docId);

      //Then, we update the promotion with the image path
      Map<String, dynamic> promotionImagePath = {
        "featured_image": promotionFeaturedImagePath
      };

      //Then, we update the promotion object
      promotion = promotion.copyWith(
        featuredImage: promotionFeaturedImagePath,
        documentId: docId,
      );

      //Then, we update the promotion in the database
      await firestoreService.editDocumentByDocumentId(
        promotionsCollection,
        docId,
        promotionImagePath,
      );

      //Finally, we update the state
      emit(state.copyWith(
          status: BusinessViewCubitStatus.success,
          promotions: [promotion, ...state.promotions]));

      return true;
    } catch (e) {
      log('Error: $e, Function: createPromotion, File: owned_business_details_cubit.dart',
          stackTrace: StackTrace.current);
      return false;
    }
  }

  Future<bool> editPromotion(
    Map<String, dynamic> promotionMap,
    Promotion promotion,
  ) async {
    try {
      //First, we create the promotion object
      var promotionToEdit = Promotion(
        documentId: promotion.documentId,
        title: promotionMap["title"]!.value,
        description: promotionMap["description"]!.value,
        instructions: promotionMap["instructions"]!.value,
        percentage: int.parse(promotionMap["percentage"]!.value),
        expiredAt: promotionMap["expirationDate"]!.value,
        featuredImage: promotion.featuredImage,
        businessId: promotionMap["business_id"]!,
        status: promotionMap["status"]!.value,
      );

      //Then, we get the firestore service and the promotions collection
      final firestoreService = locator.get<FirestoreService>();
      final promotionsCollection =
          locator.get<AppConstants>().advertisementCollection;

      //Then, we update the promotion in the database
      final editedPromotion = Promotion.fromJson(
        await firestoreService.editDocumentByDocumentId(
          promotionsCollection,
          promotion.documentId!,
          promotionToEdit.toJson(),
        ),
      );

      //Then, we update the promotion inside the state
      final idOfPromotion = state.promotions.indexWhere(
        (element) => element.documentId == promotion.documentId,
      );

      final newPromotions = [...state.promotions];
      newPromotions[idOfPromotion] = editedPromotion;

      //Finally, we update the state
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.success,
          promotions: newPromotions,
        ),
      );

      return true;
    } catch (e) {
      log('Error: $e, Function: editPromotion, File: owned_business_details_cubit.dart',
          stackTrace: StackTrace.current);
      return false;
    }
  }

  Future<bool> deletePromotion(Promotion promotion) async {
    try {
      //First, we get the firestore service and the promotions collection
      final firestoreService = locator.get<FirestoreService>();
      final fireStorageService = locator.get<FireStorageService>();
      final promotionsCollection =
          locator.get<AppConstants>().advertisementCollection;

      //Then, we delete the promotion in the database and the image in the storage
      await fireStorageService.deletePromotionFeaturedImage(promotion);

      await firestoreService.deleteDocumentByDocumentId(
          promotionsCollection, promotion.documentId!);

      //Then, we update the promotion inside the state
      final idOfPromotion = state.promotions.indexWhere(
        (element) => element.documentId == promotion.documentId!,
      );
      final newPromotions = [...state.promotions];
      newPromotions.removeAt(idOfPromotion);

      //Finally, we update the state
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.success,
          promotions: newPromotions,
        ),
      );

      return true;
    } catch (e) {
      log('Error: $e, Function: deletePromotion, File: owned_business_details_cubit.dart',
          stackTrace: StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteManagerFromBusiness(
      String businessId, String userId) async {
    try {
      //First, we get the firestore service and the users collection
      final firestoreService = locator.get<FirestoreService>();
      final usersCollection = locator.get<AppConstants>().usersCollection;

      //Then, we delete the business from the user owned_businesses array
      await firestoreService.deletePropertyFromArray(
        usersCollection,
        userId,
        "uid",
        "owned_businesses",
        businessId,
      );

      //Then, we delete the user from the business managers array in the state
      final idOfManager = state.allManagers.indexWhere(
        (element) => element.uid == userId,
      );
      final newManagers = [...state.allManagers];
      newManagers.removeAt(idOfManager);

      //Finally, we update the state
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.success,
          allManagers: newManagers,
        ),
      );

      return true;
    } catch (e) {
      log('Error: $e, Function: deleteManagerFromBusiness, File: owned_business_details_cubit.dart',
          stackTrace: StackTrace.current);
      return false;
    }
  }

  Future<bool> addManagerToBusiness(String userEmail, String businessId) async {
    try {
      //First, we get the firestore service and the users collection
      final firestoreService = locator.get<FirestoreService>();
      final usersCollection = locator.get<AppConstants>().usersCollection;

      //Then, we get the user by email
      final rawUser = await firestoreService.readActiveDocumentsByCondition(
        usersCollection,
        "email",
        userEmail,
        1,
      );

      //If the user does not exist, we return false
      if (rawUser.isEmpty) {
        log("raw user$rawUser");
        return false;
      }

      final user = ListableUserModel.fromJson(rawUser.first);

      //If the user already manages the business, we return false
      if (user.managedBusinesses.contains(businessId)) {
        return false;
      }

      //Then, we add the business id to the user owned_businesses array in the database
      await firestoreService.editDocumentById(
        usersCollection,
        user.uid,
        "uid",
        {
          "owned_businesses": [...user.managedBusinesses, businessId],
        },
      );

      //Then, we add the user to the business managers array in the state
      final newManagers = [...state.allManagers, user];

      //Finally, we update the state
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.success,
          allManagers: newManagers,
        ),
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
