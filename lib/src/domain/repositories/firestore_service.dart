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
      String collectionName, String id) async {
    final docSnapshot =
        await _firestore.collection(collectionName).doc(id).get();
    return docSnapshot.data() as Map<String, dynamic>;
  }
}
