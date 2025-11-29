import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Add data to a collection
  Future<void> add({
    required String collection,
    required Map<String, dynamic> data,
    String? docId,
  }) async {
    if (docId != null) {
      await _db.collection(collection).doc(docId).set(data);
    } else {
      await _db.collection(collection).add(data);
    }
  }

  /// Update document
  Future<void> update({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  /// Delete document
  Future<void> delete({
    required String collection,
    required String docId,
  }) async {
    await _db.collection(collection).doc(docId).delete();
  }

  /// Fetch all documents
  Stream<List<Map<String, dynamic>>> fetchCollection(String collection) {
    return _db
        .collection(collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return {"id": doc.id, ...doc.data()};
          }).toList(),
        );
  }

  /// Fetch a single document
  Stream<Map<String, dynamic>?> fetchDoc({
    required String collection,
    required String docId,
  }) {
    return _db.collection(collection).doc(docId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return {"id": doc.id, ...doc.data()!};
    });
  }
}
