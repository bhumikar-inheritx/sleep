import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic methods for CRUD
  Future<void> setData(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  Future<Map<String, dynamic>?> getData(String collection, String docId) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getCollection(String collection, {String? userId}) async {
    Query query = _firestore.collection(collection);
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> deleteData(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }
}
