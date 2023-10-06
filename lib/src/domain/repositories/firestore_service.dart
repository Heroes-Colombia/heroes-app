import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createDocument(
      String collectionName, Map<String, dynamic> data) async {
    final docRef = await _firestore.collection(collectionName).add(data);

    return docRef.id;
  }

  Future<Map<String, dynamic>> readDocumentById(
      String collectionName, String id, String property) async {
    final docSnapshot = await _firestore
        .collection(collectionName)
        .where(property, isEqualTo: id)
        .get();
    return docSnapshot.docs.first.data();
  }

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
}
