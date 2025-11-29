import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillcast/features/courses/domain/course_model.dart';

class CourseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCourse(CourseModel course) async {
    await _firestore.collection('courses').doc(course.id).set(course.toMap());
  }

  Stream<List<CourseModel>> getAllCourses() {
    return _firestore.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CourseModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<CourseModel?> getCourse(String courseId) async {
    final doc = await _firestore.collection('courses').doc(courseId).get();

    if (!doc.exists || doc.data() == null) return null;

    return CourseModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateCourse(String courseId, Map<String, dynamic> data) async {
    await _firestore.collection('courses').doc(courseId).update(data);
  }

  Future<void> deleteCourse(String courseId) async {
    await _firestore.collection('courses').doc(courseId).delete();
  }

  Future<void> enrollUser(String courseId, String userId) async {
    await _firestore.collection('enrollments').doc().set({
      'courseId': courseId,
      'userId': userId,
      'enrolledAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });
  }

  Stream<bool> isUserEnrolled(String courseId, String userId) {
    return _firestore
        .collection('enrollments')
        .where('courseId', isEqualTo: courseId)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }

  Stream<List<String>> getUserEnrolledCourseIds(String userId) {
    return _firestore
        .collection('enrollments')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => doc['courseId'] as String).toList(),
        );
  }

  Future<void> unEnrollUser(String courseId, String userId) async {
    final snap = await _firestore
        .collection('enrollments')
        .where('courseId', isEqualTo: courseId)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    for (var doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
