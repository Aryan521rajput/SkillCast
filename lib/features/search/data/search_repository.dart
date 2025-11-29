import 'package:cloud_firestore/cloud_firestore.dart';
import '../../courses/domain/course_model.dart';
import '../../lessons/domain/lesson_model.dart';
import '../../live/domain/live_class_model.dart';

class SearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SEARCH COURSES
  Future<List<CourseModel>> searchCourses(String query) async {
    final result = await _firestore
        .collection('courses')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: "$query\uf8ff")
        .get();

    return result.docs
        .map((doc) => CourseModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // SEARCH LESSONS
  Future<List<LessonModel>> searchLessons(String query) async {
    final result = await _firestore
        .collection('lessons')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: "$query\uf8ff")
        .get();

    return result.docs
        .map((doc) => LessonModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // SEARCH LIVE CLASSES
  Future<List<LiveClassModel>> searchLiveClasses(String query) async {
    final result = await _firestore
        .collection('live_classes')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: "$query\uf8ff")
        .get();

    return result.docs
        .map((doc) => LiveClassModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
