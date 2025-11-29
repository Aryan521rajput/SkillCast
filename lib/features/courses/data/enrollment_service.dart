import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> enrollUser(String userId, String courseId) async {
    await _firestore.collection('enrollments').add({
      'userId': userId,
      'courseId': courseId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<bool> isUserEnrolled(String userId, String courseId) {
    return _firestore
        .collection('enrollments')
        .where('userId', isEqualTo: userId)
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }
}
