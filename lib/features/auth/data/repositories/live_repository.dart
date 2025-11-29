import 'package:cloud_firestore/cloud_firestore.dart';

class LiveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createLiveClass({
    required String title,
    required String description,
    required String instructorId,
    required String meetUrl,
  }) async {
    final id = _firestore.collection('live_classes').doc().id;

    await _firestore.collection('live_classes').doc(id).set({
      'id': id,
      'title': title,
      'description': description,
      'instructorId': instructorId,
      'meetUrl': meetUrl,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> getAllLiveClasses() {
    return _firestore
        .collection('live_classes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }
}
