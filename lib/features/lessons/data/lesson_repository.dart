import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/lesson_model.dart';

class LessonRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// --------------------------------------------------------
  /// GET ALL LESSONS FOR A COURSE
  /// Safe against missing createdAt field & bad ordering
  /// --------------------------------------------------------
  Stream<List<LessonModel>> getLessons(String courseId) {
    final query = _db
        .collection('lessons')
        .where('courseId', isEqualTo: courseId);

    return query.snapshots().map((snapshot) {
      final lessons = snapshot.docs
          .map((doc) => LessonModel.fromMap(doc.id, doc.data()))
          .toList();

      // Sort safely by createdAt (if missing, put last)
      lessons.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return a.createdAt!.compareTo(b.createdAt!);
      });

      return lessons;
    });
  }

  /// --------------------------------------------------------
  /// GET SINGLE LESSON
  /// --------------------------------------------------------
  Future<LessonModel?> getLesson(String id) async {
    final doc = await _db.collection('lessons').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return LessonModel.fromMap(doc.id, doc.data()!);
  }
}
