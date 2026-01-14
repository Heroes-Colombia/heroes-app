import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

//This class is a wrapper for Firestore
class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //This method is used to create a document inside a collection
  Future<String> createDocument(
    String collectionName,
    Map<String, dynamic> data,
  ) async {
    final docRef = await _firestore.collection(collectionName).add(data);
    return docRef.id;
  }

  /*
   This method is used to read all documents inside a collection,
   where the id  of the property is equal to the id passed as parameter
   example 'usersCollectionName', '123', 'uid'
  */
  Future<Map<String, dynamic>> readDocumentById(
    String collectionName,
    String id,
    String property,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where(property, isEqualTo: id)
            .get();

    if (docSnapshot.docs.isEmpty) {
      throw Exception(
        'No document found with $property: $id in collection $collectionName',
      );
    }

    return docSnapshot.docs.first.data();
  }

  /*
   This method is used to edit a document inside a collection with the data passed as parameter,
   where the id  of the property is equal to the id passed as parameter
   example 'usersCollectionName', '123', 'uid', '{name: 'John'}'

   Note: Automatically adds updated_at timestamp to all updates for audit trail
  */
  Future<Map<String, dynamic>> editDocumentById(
    String collectionName,
    String id,
    String property,
    Map<String, dynamic> data,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where(property, isEqualTo: id)
            .get();
    final docId = docSnapshot.docs.first.id;

    // Automatically add updated_at timestamp for audit trail
    final dataWithTimestamp = {
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    };

    await _firestore.collection(collectionName).doc(docId).update(dataWithTimestamp);
    return data;
  }

  /*
   This method is used to edit a document inside a collection with the data passed as parameter,
   where the document id is equal to the id passed as parameter
   example 'usersCollectionName', '123', 'uid', '{name: 'John'}'

   Note: Automatically adds updated_at timestamp to all updates for audit trail
  */
  Future<Map<String, dynamic>> editDocumentByDocumentId(
    String collectionName,
    String id,
    Map<String, dynamic> data,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where(FieldPath.documentId, isEqualTo: id)
            .get();
    final docId = docSnapshot.docs.first.id;

    // Automatically add updated_at timestamp for audit trail
    final dataWithTimestamp = {
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    };

    await _firestore.collection(collectionName).doc(docId).update(dataWithTimestamp);
    final documentId = docSnapshot.docs.first.id;
    Map<String, dynamic> copyOfData = Map.from(data);
    copyOfData["id"] = documentId;
    return copyOfData;
  }

  /*
   This method is used to delete a document inside a collection 
   where the document id is equal to the id passed as parameter
  */
  Future<void> deleteDocumentByDocumentId(
    String collectionName,
    String id,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where(FieldPath.documentId, isEqualTo: id)
            .get();
    final docId = docSnapshot.docs.first.id;
    await _firestore.collection(collectionName).doc(docId).delete();
  }

  /*
   This method is used to delete a document inside a collection 
   where the UNIQUE property is equal to the property value passed as parameter
  */
  Future<void> deleteDocumentByDocumentProperty(
    String collectionName,
    String property,
    String valueOfProperty,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where(property, isEqualTo: valueOfProperty)
            .get();
    final docId = docSnapshot.docs.first.id;
    await _firestore.collection(collectionName).doc(docId).delete();
  }

  /*
   This method is used to set inactive a document inside a collection 
   where the UNIQUE property is equal to the property value passed as parameter
  */
  Future<void> makeDocumentInactive(
    String collectionName,
    String property,
    String valueOfProperty,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where(property, isEqualTo: valueOfProperty)
            .get();
    final docId = docSnapshot.docs.first.id;
    await _firestore.collection(collectionName).doc(docId).update({
      "status": "inactive",
    });
  }

  /*
  This method is used to get a document by the document id
  */
  Future<Map<String, dynamic>?> readDocumentByDocId(
    String collectionName,
    String docId,
  ) async {
    final docSnapshot =
        await _firestore.collection(collectionName).doc(docId).get();
    return docSnapshot.data();
  }

  /*
   This method is used to read all documents inside a collection,
   where the condition of the property is equal to the propertyValue
   passed as parameter and the status is active
  */
  Future<List<Map<String, dynamic>>> readActiveDocumentsByCondition(
    String collectionName,
    String property,
    Object propertyValue,
    int limit,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .limit(limit)
            .where("status", isEqualTo: "active")
            .where(property, isEqualTo: propertyValue)
            .get();
    final data =
        docSnapshot.docs.map((e) {
          final data = e.data();
          data["id"] = e.id;
          return data;
        }).toList();
    return data;
  }

  /*
   This method is used to read active documents with pagination support.
   Returns a map with 'documents', 'lastDocument' (cursor), and 'hasMore' flag.
   Use this for infinite scroll implementations.
  */
  Future<Map<String, dynamic>> readActiveDocumentsWithPagination(
    String collectionName, {
    required String orderByField,
    required int limit,
    DocumentSnapshot? startAfterDocument,
    String? whereField,
    dynamic whereValue,
  }) async {
    try {
      Query query = _firestore
          .collection(collectionName)
          .where('status', isEqualTo: 'active');

      // Add optional where clause
      if (whereField != null && whereValue != null) {
        query = query.where(whereField, isEqualTo: whereValue);
      }

      // Order by field (required for pagination)
      query = query.orderBy(orderByField, descending: true);

      // Pagination: start after last document
      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      // Limit results
      query = query.limit(limit);

      final querySnapshot = await query.get();

      // Extract documents and add id field
      final documents =
          querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();

      final lastDoc =
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

      return {
        'documents': documents,
        'lastDocument': lastDoc,
        'hasMore':
            querySnapshot.docs.length ==
            limit, // If we got full limit, there might be more
      };
    } catch (e) {
      log('Error reading paginated documents: $e');
      rethrow;
    }
  }

  /*
   This method is used to read all documents inside a collection,
   where the condition of the property is equal to the propertyValue
   passed as parameter
  */
  Future<List<Map<String, dynamic>>> readAllDocumentsByCondition(
    String collectionName,
    String property,
    Object propertyValue,
    int limit,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .limit(limit)
            .where(property, isEqualTo: propertyValue)
            .get();
    final data =
        docSnapshot.docs.map((e) {
          final data = e.data();
          data["id"] = e.id;
          return data;
        }).toList();
    return data;
  }

  /*
   This method is used to read all documents inside a collection,
   where the condition of the property is equal to the propertyValue 
   passed as parameter
  */
  Future<Map<String, dynamic>> readDocumentByCondition(
    String collectionName,
    String property,
    Object propertyValue,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where(property, isEqualTo: propertyValue)
            .get();
    final data = docSnapshot.docs.map((e) {
      final data = e.data();
      data["id"] = e.id;
      return data;
    });
    return data.first;
  }

  /*
   This method is used to read all documents inside a collection,
   where the condition of the property is equal to the propertyValue 
   passed as parameter
  */
  Future<List<Map<String, dynamic>>> readCreatedDocumentsByCondition(
    String collectionName,
    String property,
    Object propertyValue,
    int limit,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .limit(limit)
            .where("status", isEqualTo: "CREATED")
            .where(property, isEqualTo: propertyValue)
            .get();
    final data =
        docSnapshot.docs.map((e) {
          final data = e.data();
          return data;
        }).toList();
    return data;
  }

  /*
   This method is used to read all documents inside a collection 
   where the condition of the property is equal to the propertyValue
  */
  Future<List<Map<String, dynamic>>> readAllDocumentsInCollection(
    String collectionName,
    String property,
    Object propertyValue,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where(property, isEqualTo: propertyValue)
            .get();
    final data =
        docSnapshot.docs.map((e) {
          final data = e.data();
          data["id"] = e.id;
          return data;
        }).toList();
    return data;
  }

  /*
   This method is used to read all documents inside a collection,
   where the condition status is equal to active
  */
  Future<List<Map<String, dynamic>>> readAllActiveDocuments(
    String collectionName,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where("status", isEqualTo: "active")
            .get();

    final data =
        docSnapshot.docs.map((e) {
          final data = e.data();
          data["id"] = e.id;
          return data;
        }).toList();
    return data;
  }

  /*
   This method is used to read all documents inside a collection,
   where the search query is contained in the property passed as parameter
  */
  Future<List<Map<String, dynamic>>> readActiveDocumentsBySearchQuery(
    String collectionName,
    String property,
    String searchQuery,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where("status", isEqualTo: "active")
            .orderBy("name")
            .startAt([searchQuery])
            .endAt(['$searchQuery\uf8ff'])
            .get();

    final data =
        docSnapshot.docs.map((e) {
          final data = e.data();
          data["id"] = e.id;
          return data;
        }).toList();

    return data;
  }

  /*
   This method is used to read all documents inside a collection,
   where the passed ids are contained in the document ids
  */
  Future<List<Map<String, dynamic>>> readActiveDocumentsByDocumentIDs(
    String collectionName,
    List<String> ids,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where("status", isEqualTo: "active")
            .where(FieldPath.documentId, whereIn: ids)
            .get();

    final data =
        docSnapshot.docs.map((e) {
          final data = e.data();
          data["id"] = e.id;
          return data;
        }).toList();

    return data;
  }

  /*
   This method is used to read all documents inside a collection,
   where the passed ids are contained in the document ids
  */
  Future<List<Map<String, dynamic>>> readAllDocumentsByDocumentIDs(
    String collectionName,
    List<String> ids,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where(FieldPath.documentId, whereIn: ids)
            .get();

    final data =
        docSnapshot.docs.map((e) {
          final data = e.data();
          data["id"] = e.id;
          return data;
        }).toList();

    return data;
  }

  /*
   This method is used to batch read business names by document IDs
   Optimized for promotions: returns only id and name fields
   Note: Firestore whereIn queries are limited to 30 items per batch
  */
  Future<Map<String, String>> readBusinessNamesByIds(
    String collectionName,
    List<String> ids,
  ) async {
    if (ids.isEmpty) return {};

    // Firestore whereIn limit is 30, so we need to batch if more than 30 ids
    final Map<String, String> businessNames = {};
    const batchSize = 30;

    for (var i = 0; i < ids.length; i += batchSize) {
      final batchIds = ids.sublist(
        i,
        i + batchSize > ids.length ? ids.length : i + batchSize,
      );

      final docSnapshot =
          await _firestore
              .collection(collectionName)
              .where(FieldPath.documentId, whereIn: batchIds)
              .get();

      for (var doc in docSnapshot.docs) {
        final data = doc.data();
        if (data['name'] != null) {
          businessNames[doc.id] = data['name'] as String;
        }
      }
    }

    return businessNames;
  }

  /*
   This method is used to read all documents inside a array property of a document,
   where the passed id are contained in the document passed property
  */
  Future<List<Map<String, dynamic>>> readDocumentsWhereArrayContainsId(
    String collectionName,
    String property,
    String id,
  ) async {
    final docSnapshot =
        await _firestore
            .collection(collectionName)
            .where(property, arrayContains: id)
            .get();

    final data =
        docSnapshot.docs.map((e) {
          final data = e.data();
          data["id"] = e.id;
          return data;
        }).toList();

    return data;
  }

  /*
   This method is used to delete a value from an array property of a document,
   where the passed id are contained in the document passed propertyToSearch
  */
  Future<List<dynamic>> deletePropertyFromArray(
    String collectionName,
    String userId,
    String propertyToSearch,
    String propertyToEdit,
    String businessId,
  ) async {
    //First we get the document to edit
    final document = await readDocumentById(
      collectionName,
      userId,
      propertyToSearch,
    );

    //Then we get the array to edit
    final array = document[propertyToEdit] as List<dynamic>;

    //Then we delete the value from the array
    array.remove(businessId);

    //Then we edit the document
    await editDocumentById(collectionName, userId, propertyToSearch, {
      propertyToEdit: array,
    });

    return array;
  }

  /*
   This method is used to get the documents inside a collection,
   where the docs are in the distance in Km passed as parameter 
   to the location passed as parameter
  */
  Stream<List<DocumentSnapshot<Object?>>> getDocumentsNearPosition(
    GeoPoint location,
    double maxDistance,
    String collection,
  ) {
    GeoFirePoint center = GeoFirePoint(
      GeoPoint(location.latitude, location.longitude),
    );
    final CollectionReference<Map<String, dynamic>> collectionReference =
        _firestore.collection(collection);

    double radius = maxDistance;
    String field = 'geo_hash';

    //Function to get GeoPoint instance from the location
    GeoPoint geopointFrom(Map<String, dynamic> data) {
      final geoHashData = data['geo_hash'] as Map<String, dynamic>;
      final geopointData = geoHashData['geopoint'];

      // Handle both GeoPoint and Map formats
      if (geopointData is GeoPoint) {
        return geopointData;
      } else if (geopointData is Map<String, dynamic>) {
        return GeoPoint(
          geopointData['latitude'] as double,
          geopointData['longitude'] as double,
        );
      } else {
        throw Exception('Invalid geopoint data format');
      }
    }

    final Stream<List<DocumentSnapshot<Map<String, dynamic>>>> stream =
        GeoCollectionReference<Map<String, dynamic>>(
          collectionReference,
        ).subscribeWithin(
          center: center,
          radiusInKm: radius,
          field: field,
          geopointFrom: geopointFrom,
        );

    return stream;
  }

  /* This method fetches all locations for a specific business
   from the locations subcollection
  */
  Future<List<Map<String, dynamic>>> getBusinessLocations(
    String businessId,
  ) async {
    try {
      final locationsSnapshot =
          await _firestore
              .collection('businesses')
              .doc(businessId)
              .collection('locations')
              .where('status', isEqualTo: 'active')
              .get();

      return locationsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /*
   This method fetches locations for multiple businesses
   Used in map view to display all locations from nearby businesses
   OPTIMIZED: Uses parallel execution with Future.wait for 10-20x performance improvement
  */
  Future<Map<String, List<Map<String, dynamic>>>> getMultipleBusinessLocations(
    List<String> businessIds,
  ) async {
    try {
      // ✅ OPTIMIZED: Fetch all locations in parallel using Future.wait
      final locationFutures = businessIds.map((businessId) async {
        final locations = await getBusinessLocations(businessId);
        return MapEntry(businessId, locations);
      });

      // Wait for all requests to complete in parallel
      final results = await Future.wait(locationFutures);

      // Filter out empty results and convert to map
      return Map.fromEntries(results.where((entry) => entry.value.isNotEmpty));
    } catch (e) {
      return {};
    }
  }

  /*
   This method gets documents near a position and their locations subcollection
   Returns a stream of businesses with their locations included
  */
  Stream<Map<String, dynamic>> getDocumentsNearPositionWithLocations(
    GeoPoint position,
    double maxDistance,
    String collection,
  ) async* {
    // First get nearby businesses
    final businessStream = getDocumentsNearPosition(
      position,
      maxDistance,
      collection,
    );

    await for (final businessDocs in businessStream) {
      final Map<String, dynamic> result = {'businesses': [], 'locations': {}};

      List<Map<String, dynamic>> businesses = [];
      for (var doc in businessDocs) {
        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          businesses.add(data);
        }
      }

      result['businesses'] = businesses;

      // Fetch locations for all businesses
      final businessIds = businesses.map((b) => b['id'] as String).toList();
      final locationsMap = await getMultipleBusinessLocations(businessIds);
      result['locations'] = locationsMap;

      yield result;
    }
  }

  /*
   This method fetches ALL active businesses with their physical locations
   Returns a list of maps containing business info + location info for each physical location
   Used for client-side search in map view (supports partial matching & category search)
  */
  Future<List<Map<String, dynamic>>> getAllBusinessesWithPhysicalLocations(
    String collectionName,
  ) async {
    try {
      // Fetch ALL active businesses (client-side filtering will be done in the cubit)
      final businessesSnapshot =
          await _firestore
              .collection(collectionName)
              .where("status", isEqualTo: "active")
              .where("type", isEqualTo: "physical")
              .get();

      final List<Map<String, dynamic>> results = [];

      // For each business, fetch its physical locations
      for (var businessDoc in businessesSnapshot.docs) {
        final businessData = businessDoc.data();
        businessData['id'] = businessDoc.id;

        // Fetch locations subcollection
        final locationsSnapshot =
            await _firestore
                .collection(collectionName)
                .doc(businessDoc.id)
                .collection('locations')
                .where('status', isEqualTo: 'active')
                .where('type', isEqualTo: 'physical')
                .get();

        // Add each physical location as a separate result
        for (var locationDoc in locationsSnapshot.docs) {
          final locationData = locationDoc.data();
          locationData['id'] = locationDoc.id;

          // Combine business and location data
          results.add({
            'businessId': businessDoc.id,
            'businessName': businessData['name'],
            'businessAddress': businessData['address'],
            'businessLocation': businessData['location'],
            'businessPhoneNumber': businessData['phone_number'],
            'businessCategories': businessData['categories'] ?? [],
            'locationId': locationDoc.id,
            'locationData': locationData,
          });
        }
      }

      return results;
    } catch (e) {
      log('Error fetching all businesses with physical locations: $e');
      return [];
    }
  }

  /*
   This method returns a stream of ALL active physical businesses
   Used for map view to display all businesses across Colombia without distance restrictions
  */
  Stream<List<DocumentSnapshot<Object?>>> getAllActivePhysicalBusinesses(
    String collection,
  ) {
    final CollectionReference<Map<String, dynamic>> collectionReference =
        _firestore.collection(collection);

    // Stream all active physical businesses
    return collectionReference
        .where('status', isEqualTo: 'active')
        .where('type', isEqualTo: 'physical')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  /*
   This method fetches ALL active businesses for client-side search
   Used for search functionality with case-insensitive and substring matching
  */
  Future<List<Map<String, dynamic>>> getAllActiveBusinessesForSearch(
    String collectionName,
  ) async {
    try {
      final docSnapshot =
          await _firestore
              .collection(collectionName)
              .where("status", isEqualTo: "active")
              .get();

      final data =
          docSnapshot.docs.map((e) {
            final data = e.data();
            data["id"] = e.id;
            return data;
          }).toList();

      return data;
    } catch (e) {
      log('Error fetching all active businesses: $e');
      return [];
    }
  }

  /*
   This method fetches ALL active promotions for client-side search
   Used for search functionality with case-insensitive and substring matching
  */
  Future<List<Map<String, dynamic>>> getAllActivePromotionsForSearch(
    String collectionName,
  ) async {
    try {
      final docSnapshot =
          await _firestore
              .collection(collectionName)
              .where("status", isEqualTo: "active")
              .get();

      final data =
          docSnapshot.docs.map((e) {
            final data = e.data();
            data["id"] = e.id;
            return data;
          }).toList();

      return data;
    } catch (e) {
      log('Error fetching all active promotions: $e');
      return [];
    }
  }
}
