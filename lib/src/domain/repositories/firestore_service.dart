import 'package:cloud_firestore/cloud_firestore.dart';

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
   passed as parameter
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
}
