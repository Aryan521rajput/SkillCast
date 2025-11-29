// lib/lessons/data/lesson_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../lessons/domain/lesson_model.dart';

class LessonRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addLesson({
    required String courseId,
    required String title,
    String? videoUrl,
  }) async {
    final lessonId = _firestore.collection('lessons').doc().id;
    await _firestore.collection('lessons').doc(lessonId).set({
      'id': lessonId,
      'courseId': courseId,
      'title': title,
      'content': '',
      'videoUrl': videoUrl ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<LessonModel>> getLessons(String courseId) {
    return _firestore
        .collection('lessons')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => LessonModel.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<LessonModel?> getLesson(String id) async {
    final doc = await _firestore.collection('lessons').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return LessonModel.fromMap(doc.id, doc.data()!);
  }
}
