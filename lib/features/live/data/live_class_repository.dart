// lib/live/data/live_class_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/live_class_model.dart';

class LiveClassRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createLiveClass(LiveClassModel live) async {
    await _firestore.collection('live_classes').doc(live.id).set(live.toMap());
  }

  Stream<List<LiveClassModel>> getLiveClasses() {
    return _firestore.collection('live_classes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LiveClassModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<LiveClassModel?> getLiveClass(String id) async {
    final doc = await _firestore.collection('live_classes').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;

    return LiveClassModel.fromMap(doc.id, doc.data()!);
  }
}
