import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

//This class is a wrapper for Firestore
class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //This method is used to create a document inside a collection
  Future<String> createDocument(
      String collectionName, Map<String, dynamic> data) async {
    final docRef = await _firestore.collection(collectionName).add(data);
    return docRef.id;
  }

  /*
   This method is used to read all documents inside a collection,
   where the id  of the property is equal to the id passed as parameter
   example 'usersCollectionName', '123', 'uid'
  */
  Future<Map<String, dynamic>> readDocumentById(
      String collectionName, String id, String property) async {
    final docSnapshot = await _firestore
        .collection(collectionName)
        .where(property, isEqualTo: id)
        .get();
    return docSnapshot.docs.first.data();
  }

  /*
   This method is used to edit a document inside a collection with the data passed as parameter,
   where the id  of the property is equal to the id passed as parameter
   example 'usersCollectionName', '123', 'uid', '{name: 'John'}'
  */
  Future<Map<String, dynamic>> editDocumentById(String collectionName,
      String id, String property, Map<String, dynamic> data) async {
    final docSnapshot = await _firestore
        .collection(collectionName)
        .where(property, isEqualTo: id)
        .get();
    final docId = docSnapshot.docs.first.id;
    await _firestore.collection(collectionName).doc(docId).update(data);
    return data;
  }

  /*
   This method is used to edit a document inside a collection with the data passed as parameter,
   where the document id is equal to the id passed as parameter
   example 'usersCollectionName', '123', 'uid', '{name: 'John'}'
  */
  Future<Map<String, dynamic>> editDocumentByDocumentId(
      String collectionName, String id, Map<String, dynamic> data) async {
    final docSnapshot = await _firestore
        .collection(collectionName)
        .where(FieldPath.documentId, isEqualTo: id)
        .get();
    final docId = docSnapshot.docs.first.id;
    await _firestore.collection(collectionName).doc(docId).update(data);
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
      String collectionName, String id) async {
    final docSnapshot = await _firestore
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
      String collectionName, String property, String valueOfProperty) async {
    final docSnapshot = await _firestore
        .collection(collectionName)
        .where(property, isEqualTo: valueOfProperty)
        .get();
    final docId = docSnapshot.docs.first.id;
    await _firestore.collection(collectionName).doc(docId).delete();
  }

  /*
  This method is used to get a document by the document id
  */
  Future<Map<String, dynamic>?> readDocumentByDocId(
      String collectionName, String docId) async {
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
    final docSnapshot = await _firestore
        .collection(collectionName)
        .limit(limit)
        .where("status", isEqualTo: "active")
        .where(property, isEqualTo: propertyValue)
        .get();
    final data = docSnapshot.docs.map((e) {
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
    final docSnapshot = await _firestore
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
    final docSnapshot = await _firestore
        .collection(collectionName)
        .limit(limit)
        .where("status", isEqualTo: "CREATED")
        .where(property, isEqualTo: propertyValue)
        .get();
    final data = docSnapshot.docs.map((e) {
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
    final docSnapshot = await _firestore
        .collection(collectionName)
        .where(property, isEqualTo: propertyValue)
        .get();
    final data = docSnapshot.docs.map((e) {
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
    final docSnapshot = await _firestore
        .collection(collectionName)
        .where("status", isEqualTo: "active")
        .get();

    final data = docSnapshot.docs.map((e) {
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
    final docSnapshot = await _firestore
        .collection(collectionName)
        .where("status", isEqualTo: "active")
        .orderBy("name")
        .startAt([searchQuery]).endAt(['$searchQuery\uf8ff']).get();

    final data = docSnapshot.docs.map((e) {
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
    final docSnapshot = await _firestore
        .collection(collectionName)
        .where("status", isEqualTo: "active")
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    final data = docSnapshot.docs.map((e) {
      final data = e.data();
      data["id"] = e.id;
      return data;
    }).toList();

    return data;
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
    final docSnapshot = await _firestore
        .collection(collectionName)
        .where(property, arrayContains: id)
        .get();

    final data = docSnapshot.docs.map((e) {
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
    final document =
        await readDocumentById(collectionName, userId, propertyToSearch);

    //Then we get the array to edit
    final array = document[propertyToEdit] as List<dynamic>;

    //Then we delete the value from the array
    array.remove(businessId);

    //Then we edit the document
    await editDocumentById(
      collectionName,
      userId,
      propertyToSearch,
      {propertyToEdit: array},
    );

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
    final geofire = GeoFlutterFire();

    GeoFirePoint center = geofire.point(
        latitude: location.latitude, longitude: location.longitude);
    var collectionReference = _firestore.collection(collection);

    double radius = maxDistance;
    String field = 'geo_hash';

    Stream<List<DocumentSnapshot>> stream = geofire
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);

    return stream;
  }
}
