import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/live_class_model.dart';

class LiveClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE
  Future<void> createLiveClass(LiveClassModel liveClass) async {
    await _firestore
        .collection('live_classes')
        .doc(liveClass.id)
        .set(liveClass.toMap());
  }

  // GET ALL LIVE CLASSES
  Stream<List<LiveClassModel>> getAllLiveClasses() {
    return _firestore.collection('live_classes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LiveClassModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // GET SINGLE LIVE CLASS
  Future<LiveClassModel?> getLiveClass(String id) async {
    final doc = await _firestore.collection('live_classes').doc(id).get();
    if (!doc.exists) return null;

    return LiveClassModel.fromMap(doc.id, doc.data()!);
  }

  // UPDATE
  Future<void> updateLiveClass(String id, Map<String, dynamic> data) async {
    await _firestore.collection('live_classes').doc(id).update(data);
  }

  // DELETE
  Future<void> deleteLiveClass(String id) async {
    await _firestore.collection('live_classes').doc(id).delete();
  }
}
