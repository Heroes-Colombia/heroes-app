// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/business_payment_method.dart';
import 'package:heroes_app/src/domain/models/business_transaction.dart';
import 'package:heroes_app/src/domain/models/listable_user_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/models/review_model.dart';
import 'package:heroes_app/src/domain/repositories/business_subscription_service.dart';
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

      final categoriesCollection =
          locator.get<AppConstants>().businessCategoryCollection;

      //We fetch the categories from the database
      final rawCategories =
          await firestoreService.readAllActiveDocuments(categoriesCollection);

      final categories =
          rawCategories.map((e) => BusinessCategory.fromJson(e)).toList();

      //We update the state with the new business details
      emit(state.copyWith(
        businessId: businessId,
        business: business,
        promotions: promotions,
        allCategories: categories,
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

  //This method is used to get all business managers
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

  //This method is used to get the latest transaction of the business
  Future<void> getLatestTransaction() async {
    try {
      //First we get the collection and the firestore service
      final transactionsCollection =
          locator.get<AppConstants>().transactionsCollection;
      final firestoreService = locator.get<FirestoreService>();

      //Then we get the latest transaction of the business
      final rawTransaction = await firestoreService.readDocumentByDocId(
        transactionsCollection,
        state.business!.latestTransactionDocumentId!,
      );

      final transaction = BusinessTransaction.fromJson(rawTransaction!);

      //Then we update the state
      emit(state.copyWith(
        latestTransaction: transaction,
      ));
    } catch (e) {
      log('Error: $e, Function: getLatestTransaction, File: owned_business_details_cubit.dart');
    }
  }

  //This method is used to get all the payment methods of a business
  Future<void> getAllPaymentMethods(String businessId) async {
    try {
      final firestoreService = locator.get<FirestoreService>();
      final paymentMethodsCollection =
          locator.get<AppConstants>().paymentMethodsCollection;

      //We fetch all the payment methods
      final rawPaymentMethods =
          await firestoreService.readCreatedDocumentsByCondition(
              paymentMethodsCollection, "business_id", businessId, 999);
      final paymentMethods =
          rawPaymentMethods.map((e) => PaymentMethod.fromJson(e)).toList();

      //Then set the payment methods in the state
      emit(state.copyWith(allPaymentMethods: paymentMethods));
    } catch (e) {
      log('Error: $e, Function: getAllCardTokens, File: owned_business_details_cubit.dart');
    }
  }

  //This method is used to create a card token with payment method Id
  Future<void> createCardToken(
      Map<String, dynamic> cardData, BuildContext context) async {
    try {
      //First, we get the business id
      final businessId = state.businessId!;

      //Then, we get the business subscription service
      final businessSubscriptionService =
          locator.get<BusinessSubscriptionService>();

      //Then, we create the card token
      final newPaymentMethod =
          await businessSubscriptionService.createCardToken(cardData);

      //Then, we get the firestore service and the payment methods collection
      final firestoreService = locator.get<FirestoreService>();
      final paymentMethodsCollection =
          locator.get<AppConstants>().paymentMethodsCollection;

      //Then, we add the business id to the payment method
      var editablePaymentMethod = newPaymentMethod.toJson();
      editablePaymentMethod["business_id"] = businessId;

      //Then, we save the payment method in the database
      await firestoreService.createDocument(
        paymentMethodsCollection,
        editablePaymentMethod,
      );

      //Then we create the paymentMethod id to the card token
      final errorCreatingMethod =
          await businessSubscriptionService.createPaymentSource(
        newPaymentMethod.id,
        state.acceptanceData["acceptance_token"],
        state.business!.email,
      );

      if (errorCreatingMethod == null) {
        //If there is no error, we get the payment method id and token from the database
        final rawPaymentMethod = await firestoreService.readDocumentByCondition(
          paymentMethodsCollection,
          "id",
          newPaymentMethod.id,
        );
        final paymentMethod = PaymentMethod.fromJson(rawPaymentMethod);

        //Then, we update the state
        emit(
          state.copyWith(
            status: BusinessViewCubitStatus.success,
            allPaymentMethods: [paymentMethod, ...state.allPaymentMethods],
          ),
        );
        if (!context.mounted) return;
        Navigator.of(context).pop();
      } else {
        //If there is an error, we save the token without the payment method id
        emit(
          state.copyWith(
            status: BusinessViewCubitStatus.success,
            allPaymentMethods: [newPaymentMethod, ...state.allPaymentMethods],
          ),
        );
        if (!context.mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      log('Error: $e, Function: createCardToken, File: owned_business_details_cubit.dart');
    }
  }

  //This method is used to create a promotion from the business
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

  //This method is used to edit a promotion from the business
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

  //This method is used to delete a promotion from the business
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

  //This method is used to delete a manager from the business
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

  //This method is used to delete a payment method from the business
  Future<bool> deletePaymentMethodFromBusiness(
      PaymentMethod paymentMethod) async {
    try {
      //First, we get the firestore service and the paymentMethod collection
      final firestoreService = locator.get<FirestoreService>();
      final paymentMethodCollection =
          locator.get<AppConstants>().paymentMethodsCollection;

      //Then, we delete the paymentMethod in the database
      await firestoreService.deleteDocumentByDocumentProperty(
          paymentMethodCollection, "id", paymentMethod.id);

      //Then, we update the promotion inside the state
      final idOfPayment = state.allPaymentMethods.indexWhere(
        (element) => element.id == paymentMethod.id,
      );
      final newPaymentMethods = [...state.allPaymentMethods];
      newPaymentMethods.removeAt(idOfPayment);

      //Finally, we update the state
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.success,
          allPaymentMethods: newPaymentMethods,
        ),
      );

      return true;
    } catch (e) {
      log('Error: $e, Function: deletePaymentMethodFromBusiness, File: owned_business_details_cubit.dart',
          stackTrace: StackTrace.current);
      return false;
    }
  }

  //This method is used to set the selected payment method in the state
  void setSelectedPaymentMethod(String paymentMethodId) {
    emit(state.copyWith(
      status: BusinessViewCubitStatus.success,
      selectedPaymentMethod: paymentMethodId,
    ));
  }

  //This method is used to set the selected promotion in the state
  Future<void> getAcceptanceToken() async {
    try {
      //First, we get the business subscription service
      final businessSubscriptionService =
          locator.get<BusinessSubscriptionService>();

      //Then, we get the acceptance token
      final data = await businessSubscriptionService.getAcceptanceToken();
      emit(state.copyWith(acceptanceData: data));
    } catch (e) {
      log('Error: $e, Function: getAcceptanceToken, File: owned_business_details_cubit.dart');
    }
  }

  //This method is used to change the user accepted terms in the state
  void changeUserAcceptedTerms(bool value) {
    emit(state.copyWith(
      userAcceptedTerms: value,
      selectedPaymentMethod: state.selectedPaymentMethod,
    ));
  }

  //This method is used to create a subscription from the business
  Future<bool> createSubscription() async {
    try {
      //First, we get the business subscription service
      final businessSubscriptionService =
          locator.get<BusinessSubscriptionService>();

      //Then, we create the subscription with the selected payment method in the cloud functions
      final paymentMethodId = state.allPaymentMethods
          .firstWhere((element) => element.id == state.selectedPaymentMethod)
          .paymentMethodId;

      //TODO: Specify the plan cost, period, etc.
      final errorCreatingTransaction =
          await businessSubscriptionService.createSubscription(
        paymentMethodId!,
        state.business!.email,
        state.businessId!,
        "plan_1",
      );

      if (errorCreatingTransaction != null) {
        return false;
      }

      return true;
    } catch (e) {
      log('Error: $e, Function: createSubscription, File: owned_business_details_cubit.dart');
      return false;
    }
  }

  //This method is used to cancel a subscription only from the business subscription status in database
  Future<void> cancelSubscription() async {
    try {
      //First, we get the firestore service and the business collection
      final firestoreService = locator.get<FirestoreService>();
      final businessCollection = locator.get<AppConstants>().businessCollection;

      //Then, we cancel the subscription in the database
      await firestoreService.editDocumentByDocumentId(
        businessCollection,
        state.businessId!,
        {
          "subscription_status":
              BusinessSubscriptionStatus.canceled.toString().split('.').last,
        },
      );

      //Then, we get the updated business
      final rawBusiness = await firestoreService.readDocumentByDocId(
        businessCollection,
        state.businessId!,
      );

      final business = Business.fromJson(rawBusiness!);

      //Finally, we update the state
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.success,
          business: business,
        ),
      );
    } catch (e) {
      log('Error: $e, Function: cancelSubscription, File: owned_business_details_cubit.dart');
    }
  }

  //This method is used to refresh the subscription status
  Future<void> refreshSubscriptionStatus() async {
    try {
      //First, we get the transaction id from the business
      final rawTransaction = await locator
          .get<FirestoreService>()
          .readDocumentByDocId(
              locator.get<AppConstants>().transactionsCollection,
              state.business!.latestTransactionDocumentId!);

      final transactionId = rawTransaction!["id"];

      //Then, we get the subscription status
      await locator
          .get<BusinessSubscriptionService>()
          .refreshTransactionStatus(transactionId);

      //Then we get the updated business
      final rawBusiness = await locator
          .get<FirestoreService>()
          .readDocumentByDocId(locator.get<AppConstants>().businessCollection,
              state.businessId!);

      final business = Business.fromJson(rawBusiness!);

      //Then, we update the state
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.success,
          business: business,
        ),
      );
    } catch (e) {
      log('Error: $e, Function: refreshSubscriptionStatus, File: owned_business_details_cubit.dart');
    }
  }

  //This method is used to add a manager to the business
  Future<void> addManagerToBusiness(
      String userEmail, String businessId, BuildContext context, texts) async {
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

      //If the user does not exist
      if (rawUser.isEmpty) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(texts["email-error"]!),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      final user = ListableUserModel.fromJson(rawUser.first);

      //If the user already manages the business
      if (user.managedBusinesses.contains(businessId)) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();

        //Show the snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(texts["user-already-mange-error"]!),
            duration: const Duration(seconds: 4),
          ),
        );
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

      Navigator.of(context).pop();
      Navigator.of(context).pop();

      //Show the snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts["manager-added"]!),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      log('Error: $e, Function: addManagerToBusiness, File: owned_business_details_cubit.dart');
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texts["email-error"]!),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  //This method is used to set the business address
  Future<bool> setAddressToBusiness(String address) async {
    try {
      //First, we get the firestore service and the users collection
      final firestoreService = locator.get<FirestoreService>();
      final businessCollection = locator.get<AppConstants>().businessCollection;

      //Then we get the business coordinates from the address
      final coordinates = await transformToLatLng(address);
      if (coordinates == null) return false;

      //Then we transform the coordinates to a geoPoint
      final geoPoint = GeoPoint(coordinates.latitude, coordinates.longitude);

      //Then we get the geoHash from the coordinates
      final geo = GeoFlutterFire();
      GeoFirePoint currentPosition = geo.point(
          latitude: coordinates.latitude, longitude: coordinates.longitude);

      //Then, we add the address and the location to the business
      await firestoreService.editDocumentByDocumentId(
        businessCollection,
        state.businessId!,
        {
          "address": address,
          "location": geoPoint,
          "geo_hash": currentPosition.data,
        },
      );

      //Then we get the updated business
      final rawBusiness = await firestoreService.readDocumentByDocId(
        businessCollection,
        state.businessId!,
      );

      final business = Business.fromJson(rawBusiness!);

      //Finally, we update the state
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.success,
          business: business,
        ),
      );

      return true;
    } catch (e) {
      log('Error: $e, Function: setAddressToBusiness, File: owned_business_details_cubit.dart');
      return false;
    }
  }

  //This method is used to transform an address to a geoPoint
  Future<Location?> transformToLatLng(String address) async {
    try {
      var location =
          await locator.get<AppMethods>().getCoordinatesFromAddress(address);
      return location;
    } catch (e) {
      log('Error: $e, Function: transformToLatLng, File: owned_business_details_cubit.dart');
      return null;
    }
  }

  //This method is used to handle the selected categories in the edit business form
  void handleSetSelectedCategory(
      String categoryId, FormFieldState<dynamic> field) {
    if (field.value == null || field.value!.contains(categoryId)) {
      return;
    } else {
      field.didChange(field.value!..add(categoryId));
    }
  }

  //This method is used to handle the removed categories in the edit business form
  void handleRemoveSelectedCategory(
      String categoryId, FormFieldState<dynamic> field) {
    if (field.value == null || !field.value!.contains(categoryId)) {
      return;
    } else {
      field.didChange(field.value!..remove(categoryId));
    }
  }

  //This method is used to update the business information
  Future<void> handleEditBusinessInformation(
      GlobalKey<FormBuilderState> editInfoKey) async {
    try {
      if (editInfoKey.currentState!.saveAndValidate()) {
        final newBusinessMap = editInfoKey.currentState!.fields;
        final business = state.business!.copyWith(
          name: newBusinessMap["name"]!.value,
          ownerName: newBusinessMap["owner_name"]!.value,
          email: newBusinessMap["email"]!.value,
          phoneNumber: newBusinessMap["phone_number"]!.value,
          identification: newBusinessMap["identification"]!.value,
          categories: (newBusinessMap["categories"]!.value as List)
              .map((e) => e.toString())
              .toList(),
        );

        final firestoreService = locator.get<FirestoreService>();
        final businessCollection =
            locator.get<AppConstants>().businessCollection;

        await firestoreService.editDocumentByDocumentId(
          businessCollection,
          state.businessId!,
          business.toJson(),
        );

        final rawBusiness = await firestoreService.readDocumentByDocId(
          businessCollection,
          state.businessId!,
        );

        final updatedBusiness = Business.fromJson(rawBusiness!);

        emit(state.copyWith(
          status: BusinessViewCubitStatus.success,
          business: updatedBusiness,
        ));
      }
    } catch (e) {
      log('Error: $e, Function: handleEditBusinessInformation, File: owned_business_details_cubit.dart');
    }
  }

  //This method is used to update a new featured image for the business
  Future<void> handleEditFeaturedImage(XFile newImage) async {
    try {
      emit(state.copyWith(status: BusinessViewCubitStatus.loading));
      final fireStorage = locator.get<FireStorageService>();
      final imagePath = await fireStorage.uploadPromotionFeaturedImage(
          newImage, state.businessId!);

      final firestoreService = locator.get<FirestoreService>();
      final businessCollection = locator.get<AppConstants>().businessCollection;

      await firestoreService.editDocumentByDocumentId(
        businessCollection,
        state.businessId!,
        {
          "featured_image": imagePath,
        },
      );

      emit(state.copyWith(
        status: BusinessViewCubitStatus.success,
        business: state.business!.copyWith(featuredImage: imagePath),
      ));
    } catch (e) {
      log('Error: $e, Function: handleEditFeaturedImage, File: owned_business_details_cubit.dart');
    }
  }

  //This method is used to clean the state on dispose
  void clearState() async {
    emit(const OwnedBusinessDetailsState());
  }
}
