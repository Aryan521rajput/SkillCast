import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/lesson_model.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<LessonModel>> getLessons(String courseId) {
    return _firestore
        .collection('lessons')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => LessonModel.fromMap(
                  doc.data() as String,
                  doc.id as Map<String, dynamic>,
                ),
              )
              .toList();
        });
  }
}
