import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/courses/domain/course_model.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GET ALL COURSES
  Stream<List<CourseModel>> getAllCourses() {
    return _firestore.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CourseModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // GET SINGLE COURSE
  Future<CourseModel?> getCourse(String id) async {
    final doc = await _firestore.collection('courses').doc(id).get();
    if (!doc.exists) return null;

    return CourseModel.fromMap(doc.id, doc.data()!);
  }

  // UPDATE COURSE
  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    await _firestore.collection('courses').doc(id).update(data);
  }

  // DELETE COURSE
  Future<void> deleteCourse(String id) async {
    await _firestore.collection('courses').doc(id).delete();
  }
}
